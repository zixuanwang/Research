from django.conf.urls.defaults import *

urlpatterns = patterns('email_usernames.views',
    url(r'^login/$', 'email_login', name="email-login"), 
)

try:
    from registration.views import register
    from email_usernames.forms import EmailRegistrationForm
    urlpatterns += patterns('', 
        url(r'^register/$', register, { 'form_class':EmailRegistrationForm }, name="email-register"),
    )
except ImportError:
    pass