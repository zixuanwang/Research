from django.db import models
from django import forms
from django.forms.fields import DateField, ChoiceField, MultipleChoiceField
from django.forms.widgets import CheckboxSelectMultiple
from myevents.models import * 
import datetime

class IndexForm(forms.Form):
	user_email = forms.EmailField()
	event_name = forms.CharField(max_length=1024,initial="Replace with your event name")

class AdminForm(forms.Form):
	eventDate = forms.DateField()
	voteDate = forms.DateField()
	emails = forms.CharField(max_length=1024)
	choice = forms.ModelMultipleChoiceField(required=False, queryset=choice.objects.all(), widget=CheckboxSelectMultiple())

class AdminFixedForm(forms.Form):
	eventDetail = forms.CharField(max_length=1024)
	eventDate = forms.DateField()
	friendEmails = forms.CharField(max_length=1024)
	zipcode = forms.CharField(max_length=10)
	city = forms.CharField(max_length=1024) 
	 
class AdminChoiceForm(forms.Form):
	choiceid = forms.CharField(max_length=1024)
	 
class ReviewForm(forms.Form):
	reviewer = forms.CharField(max_length=1024)
	review = forms.Textarea()
	
class VoteForm(forms.Form):
	def __init__(self, qs=None, *args, **kwargs):
		super(VoteForm, self).__init__(*args, **kwargs)
		self.fields['places'].queryset = qs

	choices = forms.ModelMultipleChoiceField(required=False, queryset=choice.objects.all(),  widget=CheckboxSelectMultiple())
	 

	
