# encoding: utf-8
from django.conf import settings
from django.contrib.auth.models import User
from django import forms

dummy_field = forms.EmailField()
def is_email(username):
    try:
        dummy_field.clean(username)
        return True
    except forms.ValidationError:
        return False
 
# This is an authentication backend, that allows email addresses to be used as usernames,
# which the default auth backend doesn't.
class EmailOrUsernameModelBackend(object):
    def authenticate(self, username=None, password=None):
        # If username is an email, then try to pull it up
        if is_email(username):
            try:
                user = User.objects.get(email=username)
            except User.DoesNotExist:
                return None
        else:
            # We have a non email-address we should try for username
            # This is good, because it means superusers can access the admin, without
            # using email addresses, which the admin login can't handle yet.
            try:
                user = User.objects.get(username=username)
            except User.DoesNotExist:
                return None
            
        if user.check_password(password):
            return user

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None