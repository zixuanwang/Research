# encoding: utf-8
from django import forms
from django.utils.translation import ugettext_lazy as _
from django.contrib.auth import authenticate

try:
    # If you have django-registration installed, this is a form you can
    # use for users that signup.
    from registration.forms import RegistrationFormUniqueEmail
    class EmailRegistrationForm(RegistrationFormUniqueEmail):
        def __init__(self, *args, **kwargs):
            super(EmailRegistrationForm, self).__init__(*args, **kwargs)
            del self.fields['username']

        def save(self, *args, **kwargs):
            # Note: if the username column has not been altered to allow 75 chars, this will not
            #       work for some long email addresses.
            self.cleaned_data['username'] = self.cleaned_data['email']
            return super(EmailRegistrationForm, self).save(*args, **kwargs)
except ImportError:
    pass

class EmailLoginForm(forms.Form):
    email = forms.CharField(label=_("Email"), max_length=75, widget=forms.TextInput(attrs=dict(maxlength=75)))
    password = forms.CharField(label=_(u"Password"), widget=forms.PasswordInput)

    def clean(self):
        # Try to authenticate the user
        if self.cleaned_data.get('email') and self.cleaned_data.get('password'):
            user = authenticate(username=self.cleaned_data['email'], password=self.cleaned_data['password'])
            if user is not None:
                if user.is_active:
                    self.user = user # So the login view can access it
                else:
                    raise forms.ValidationError(_("This account is inactive."))
            else:
                raise forms.ValidationError(_("Please enter a correct username and password. Note that both fields are case-sensitive."))

        return self.cleaned_data
