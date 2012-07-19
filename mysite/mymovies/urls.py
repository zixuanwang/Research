
from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.views.generic.simple import direct_to_template

urlpatterns = patterns('mymovies.views',
    url(r'^$', 'index'),
    url(r'^index/$', 'index'),
    url(r'^getNames/$', 'getNames'),
    url(r'^facebook_login/$', 'facebook_login'),
    url(r'^facebook_login_success/$', 'facebook_login_success'),
    url(r'^facebook_javascript_login_sucess/$', 'facebook_javascript_login_sucess'),
)

urlpatterns += staticfiles_urlpatterns()