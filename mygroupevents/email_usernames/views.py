from django.conf import settings
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.contrib.auth import login
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse

from forms import EmailLoginForm

def email_login(request, template="registration/login.html", extra_context=None):
    """A generic view that you can use instead of the default auth.login view, for email logins.
       On GET:
            will render the specified template with and pass the an empty EmailLoginForm as login_form
            with its context, that you can use for the login.
       On POST:
            will try to validate and authenticate the user, using the EmailLoginForm. Upon successful
            login, will redirect to whatever the standard LOGIN_REDIRECT_URL is set to, or the 'next'
            parameter, if specified."""

    if request.method == 'POST':
        login_form = EmailLoginForm(data=request.POST)
        if login_form.is_valid():
            # The user has been authenticated, so log in and redirect
            user = login(request, login_form.user)
            # Redirect to page pointed to by the 'next' param, or else just the first page
            next_page = request.REQUEST.get('next', settings.LOGIN_REDIRECT_URL)
            return HttpResponseRedirect(next_page)
    else:
        login_form = EmailLoginForm()

    context = { 'login_form':login_form, 'next':request.GET.get('next') }
    if extra_context is None: extra_context = {}
    for key, value in extra_context.items():
        if callable(value):
            context[key] = value()
        else:
            context[key] = value

    return render_to_response(template, context, context_instance=RequestContext(request))
