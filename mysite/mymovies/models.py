from django.db import models

# Create your models here.
class user(models.Model):
    uhash = models.CharField(max_length=36)
    name = models.CharField(max_length=255)
    facebookid = models.CharField(max_length=255)
    email = models.EmailField(max_length=100)
    passwd = models.CharField(max_length=100)
    access_token = models.CharField(max_length=1024)
    pub_date = models.DateTimeField(auto_now_add=True)