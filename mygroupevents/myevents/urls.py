from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.views.generic.simple import direct_to_template

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
#import the module views -- added by Jinyun 
#import views    # no need if views is a module

admin.autodiscover()

urlpatterns = patterns('myevents.views',
    url(r'^$', 'index'),
    url(r'^profile/$', 'profile'),
    url(r'^login/$', 'login'),
    url(r'^logout/$', 'logout'),
    url(r'^signup/$', 'signup'),
    url(r'^index/$', 'index'),
    url(r'^guest/$', 'guest'),
    url(r'^profile/(?P<uhash>\w+)$', 'profile'),
    url(r'^faq/$', direct_to_template,{'template': 'myevents/faq.html'}),
    url(r'^createGuestEvent/$', 'createGuestEvent'),
    url(r'^createRegisterUser/$', 'createRegisterUser'),
    url(r'^loginUser/$', 'loginUser'),
    url(r'^createEvent/$', 'createEvent'),
    url(r'(?P<ehash>\w+)/adminDetail/$', 'adminDetail'),
    url(r'(?P<ehash>\w+)/editEventAttr/$', 'editEventAttr'),
    url(r'(?P<ehash>\w+)/editEventAttrForm/$', 'editEventAttrForm'),
    url(r'(?P<ehash>\w+)/adminChoice/$', 'adminChoice'),
    url(r'(?P<ehash>\w+)/addManualChoice/$', 'addManualChoice'),
    url(r'(?P<ehash>\w+)/editEventChoice/$', 'editEventChoice'),
    url(r'(?P<ehash>\w+)/getBaseRecommendation/$', 'getBaseRecommendation'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getBaseRecommendation2/$', 'getBaseRecommendation2'),
    url(r'(?P<ehash>\w+)/getMyYelpSearchChoices/$', 'getMyYelpSearchChoices'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getMyYelpSearchChoices2/$', 'getMyYelpSearchChoices2'),
    url(r'(?P<ehash>\w+)/editEventChoice/$', 'editEventChoice'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/adminDetail/$', 'adminDetail'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/adminDetail/$', 'adminDetail'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/adminChoice/$', 'adminChoice'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/attender/$', 'attender'),
    url(r'(?P<ehash>\w+)/editEventAttr/$', 'editEventAttr'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/editEventAttr/$', 'editEventAttr'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/editEventAttrForm/$', 'editEventAttrForm'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/addManualChoice2/$', 'addManualChoice2'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/editEventChoice/$', 'editEventChoice'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getResult/$', 'getResult'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/terminateEvent/$', 'terminateEvent'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getMyPastChoices/$', 'getMyPastChoices'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getMyYelpChoices/$', 'getMyYelpChoices'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getMyYelpSearchChoices/$', 'getMyYelpSearchChoices'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getAllComments/$', 'getAllComments'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/writeComment/$', 'writeComment'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/addMoreFriends/$', 'addMoreFriends'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/addMoreChoice/$', 'addMoreChoice'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/attenderAddChoice/$', 'attenderAddChoice'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/eventSummary/$', 'eventSummary'),
    url(r'^leaveComments/$', 'leaveComments'),
    url(r'^submitReview/$', 'submitReview'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/xhr_test/$', 'xhr_test'),    #testing ajax #######below are not used calls
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getPosVote/$', 'getPosVote'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getNegVote/$', 'getNegVote'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getMyVotes/$', 'getMyVotes'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getVoteStats/$', 'getVoteStats'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/getVoteDate/$', 'getVoteDate'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/currentResult/$', 'currentResult'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/setVote/$', 'setVote'),
    url(r'(?P<ehash>\w+)/(?P<uhash>\w+)/result/$', 'pollResult'),
    url(r'(?P<ehash>\w+)/result/$', 'pollResult'),

)

urlpatterns += staticfiles_urlpatterns()

