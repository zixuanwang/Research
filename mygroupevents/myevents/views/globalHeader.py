# Create your views here.
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from django.forms.fields import ChoiceField,MultipleChoiceField

from django.core.mail import EmailMessage
from django.core.context_processors import csrf
import MySQLdb as mdb
import sys
import uuid
import datetime

from django.core.mail import send_mail

import json
import oauth2
import optparse
import urllib
import urllib2
import time
import threading

from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags

def enum(**enums):
    return type('Enum', (), enums)
def make_uuid():
    return str(uuid.uuid4().hex)

EVENT_STATUS = enum(INIT=0,HASDETAIL=1,VOTING=2,TERMINATED=3)
VOTE_STATUS = enum(NO=0,YES=1,DONTKNOW=2)
CHOICE_SOURCE = enum(MANUAL=0,YELP = 1, REC = 2)
EMAIL_HOST_USER = "mygroupevents@gmail.com"
def adminMail(ehash,uhash,user_name,event_name,send_to):
    subject = "Invitation to manage your event: " + event_name
    #url = "http://www.mygroupevents.us/myevents/" + ehash + "/" + uhash + "/adminDetail/" 
    url = "http://74.95.195.230:8889/myevents/" + ehash + "/" + uhash + "/adminDetail/" 
    
    #message = "\n You have just registered a new event using myGroupEvents called " +event_name + " ! Please Click on the  URL below to manage it:  \n"+url 
    
    html_content = render_to_string('myevents/welcomeEmailText.html', {'user_name':user_name,'event_name':event_name,'link':url})
    text_content = strip_tags(html_content) # this strips the html, so people will have the text as well.
    
    EmailThread(subject, html_content,  [send_to]).start()
    
    #if type(send_to) != list: send_to = [send_to]            
    #msg = EmailMultiAlternatives(subject, text_content, MYGROUPEMAIL, send_to)
    #msg.attach_alternative(html_content, "text/html")
    #msg.send()
    
    #send_mail(subject,message,MYGROUPEMAIL, send_to)
 
    
def getNamebyEmail(email):
    parts = email.strip().split('@')
    return parts[0]

def attenderMail(ehash,uhash, inviter,event_name,send_to):
    #generate url , url is not needed in the table, it's just good for 
    #url="http://www.mygroupevents.us/myevents/"+ehash+"/"+uhash+"/attender/"
    url= "http://74.95.195.230:8889/myevents/"+ehash+"/"+uhash+"/attender/"
     
    subject = "The event  "+ event_name +"  is waiting for your decision "
    #url_in= "http://74.95.195.230:8889/myEvents/"+e_hash+"/"+u_hash+"/admin/"
    #message = inviter +" invites you to the event "+ event_name +" and needs your decision \n Please Click on the URL below to view all choices: " +" \n" +url +" \n"
        
    html_content = render_to_string('myevents/attenderEmailText.html', {'inviter_name':inviter,'event_name':event_name,'link':url})
    
    t0=time.time()
    EmailThread(subject, html_content,  [send_to]).start()
  
    #if type(send_to) != list: send_to = [send_to]
    
    #msg = EmailMultiAlternatives(subject, text_content, MYGROUPEMAIL, send_to)
    #msg.attach_alternative(html_content, "text/html")
    #msg.send()
    print 'Time for sending emails to attendees: ', time.time()-t0
    #send_mail(subject, message, MYGROUPEMAIL, [send_to])
    #email = EmailMessage(subject,message,to=[send_to])
    #email.send()
    
def finalMessageMail(ehash):
    try:
        e = event.objects.get(ehash=ehash)
        friends = e.friends
        
        subject = "The final decision of the event: " +e.name
        #url_in= "http://192.168.50.201:8888/myEvents/"+e_hash+"/"+u_hash+"/admin/"
        #message = "Ladies and Gentlemen: \n Thanks for your participation. We made our decision for the event " + e.name +". \n  The majority agreed on: " + e.finalChoice +" \n"
        html_content = render_to_string('myevents/finalDecisionEmailText.html', {'event':e})
            
        send_to = str(e.friends).split(',')
        send_to.append(str(e.inviter))
        print send_to
    
        EmailThread(subject, html_content, send_to).start()
        #msg = EmailMultiAlternatives(subject, text_content, MYGROUPEMAIL, send_to)
        #msg.attach_alternative(html_content, "text/html")
        #msg.send()
        #try:
        #    send_mail(subject, message, MYGROUPEMAIL,[send_to],fail_silently=False)
        #except BadHeaderError:
        #    return False
        #email = EmailMessage(subject,message, to=send_to)
        #if email.send():
        #    return True
        #else:
        #    return False
    except event.DoesNotExist:
        return False

def dictfetchall(cursor):
    "Returns all rows from a cursor as a dict"
    desc = cursor.description
    return [
        dict(zip([col[0] for col in desc], row))
        for row in cursor.fetchall()
    ]    
    
    
# make yelp api call
def yelp_request(host, path, url_params, consumer_key, consumer_secret, token, token_secret):
    
  t0=time.time()
  """Returns response for API request."""
  # Unsigned URL
  encoded_params = ''
  if url_params:
    encoded_params = urllib.urlencode(url_params)
  url = 'http://%s%s?%s' % (host, path, encoded_params)
  print 'URL: %s' % (url)

  # Sign the URL
  consumer = oauth2.Consumer(consumer_key, consumer_secret)
  oauth_request = oauth2.Request('GET', url, {})
  oauth_request.update({'oauth_nonce': oauth2.generate_nonce(),
                        'oauth_timestamp': oauth2.generate_timestamp(),
                        'oauth_token': token,
                        'oauth_consumer_key': consumer_key})

  token = oauth2.Token(token, token_secret)
  oauth_request.sign_request(oauth2.SignatureMethod_HMAC_SHA1(), consumer, token)
  signed_url = oauth_request.to_url()
  print 'Signed URL: %s\n' % (signed_url,)

  # Connect
  try:
    conn = urllib2.urlopen(signed_url, None)
    try:
      response = json.loads(conn.read())
    finally:
      conn.close()
  except urllib2.HTTPError, error:
    response = json.loads(error.read())

  print 'yelp api call spent: ', time.time()-t0
  return response


class EmailThread(threading.Thread):
    def __init__(self, subject, html_content, recipient_list):
        self.subject = subject
        self.recipient_list = recipient_list
        self.html_content = html_content
        threading.Thread.__init__(self)

    def run (self):
        msg = EmailMessage(self.subject, self.html_content, EMAIL_HOST_USER, self.recipient_list)
        msg.content_subtype = "html"
        msg.send()

def send_html_mail(subject, html_content, recipient_list):
    EmailThread(subject, html_content, recipient_list).start()