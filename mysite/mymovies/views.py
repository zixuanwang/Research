# Create your views here.
from pyfb import Pyfb
from django.conf import settings
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
import urllib
import urllib2
import simplejson
from mymovies.models import *
import uuid

def index(request):
    return render_to_response('mymovies/index.html',{},context_instance=RequestContext(request))
    #return HttpResponse("""<button onclick="location.href='/facebook_login'">Facebook Login</button>""")

#This view redirects the user to facebook in order to get the code that allows
#pyfb to obtain the access_token in the facebook_login_success view
def facebook_login(request):
    facebook = Pyfb(settings.FACEBOOK_APP_ID)
    return HttpResponseRedirect(facebook.get_auth_code_url(redirect_uri=settings.FACEBOOK_REDIRECT_URL))

#This view must be refered in your FACEBOOK_REDIRECT_URL. For example: http://www.mywebsite.com/facebook_login_success/
def facebook_login_success(request):
    code = request.GET.get('code')
    facebook = Pyfb(settings.FACEBOOK_APP_ID)
    access_token = facebook.get_access_token(settings.FACEBOOK_SECRET_KEY, code, redirect_uri=settings.FACEBOOK_REDIRECT_URL)
    me = facebook.get_myself()
     
    #welcome = "Welcome <b>%s</b>. Your Facebook login has been completed successfully!"
    #return HttpResponse(welcome % me.name)
    print access_token
    
    try:
        u=user.objects.get(facebookid=me.id)
        #update access_token
        u.access_token = access_token
        u.save()
    except user.DoesNotExist:
        uhash = make_uuid()
        u = user.objects.create(uhash=uhash, name=me.name,facebookid = me.id, email=me.email, access_token=access_token)

    return render_to_response('mymovies/facebook_login_success.html',{'name':me.name,'uhash':uhash},context_instance=RequestContext(request))

#Login with the js sdk and backend queries with pyfb
def facebook_javascript_login_sucess(request):
    access_token = request.GET.get("access_token")
    facebook = Pyfb(FACEBOOK_APP_ID)
    facebook.set_access_token(access_token)
    return _render_user(facebook)

def _render_user(facebook):

    me = facebook.get_myself()

    welcome = "Welcome <b>%s</b>. Your Facebook login has been completed successfully!"
    return HttpResponse(welcome % me.name)



#### useful functions ###########
def make_uuid():
    return str(uuid.uuid4().hex)
    

