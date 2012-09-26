from django.conf.urls.defaults import *
from django.conf.urls import patterns, include, url
from django.contrib.auth.views import password_reset, password_reset_done, password_change, password_change_done
from django.views.generic.simple import direct_to_template
from django.contrib import admin
admin.autodiscover()

from registration.forms import RegistrationFormUniqueEmail


urlpatterns = patterns('',
	# url(r'^myGroups/', include('myGroups.foo.urls')),
    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    # Uncomment the next line to enable the admin:
	# url(r'^lunch/', include('lunch.urls')),
	url(r'/?', include('myevents.urls')),
	url(r'^myevents/', include('myevents.urls')),
	#url(r'^(?P<url>.*)$', 'httpproxy.views.proxy'),
	url(r'^admin/', include(admin.site.urls)),
	url(r'^accounts/register/', 'registration.views.register', {'form_class':RegistrationFormUniqueEmail, 'backend':'registration.backends.default.DefaultBackend' }),
	url(r'^accounts/', include('registration.backends.default.urls')),
)

urlpatterns += patterns('',
  #(r'^accounts/profile/$', direct_to_template, {'template': 'registration/profile.html'}),
  (r'^accounts/profile/$', direct_to_template, {'template': 'myevents/profile.html'}),
  (r'^accounts/password_reset/$', password_reset, {'template_name': 'registration/password_reset.html'}),
  (r'^accounts/password_reset_done/$', password_reset_done, {'template_name': 'registration/password_reset_done.html'}),
  (r'^accounts/password_change/$', password_change, {'template_name': 'registration/password_change.html'}),
  (r'^accounts/password_change_done/$', password_change_done, {'template_name': 'registration/password_change_done.html'}),
)

