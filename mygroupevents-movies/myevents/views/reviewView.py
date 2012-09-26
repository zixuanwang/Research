from globalHeader import *
from django.shortcuts import get_object_or_404, render_to_response
from django.template import Context, loader,RequestContext
from django.http import HttpResponse,HttpResponseRedirect
from myevents.models import * 
from myevents.forms  import IndexForm,AdminForm,VoteForm
from django.forms.fields import ChoiceField,MultipleChoiceField
from django.utils import simplejson


def leaveComments(request):   
    return render_to_response('myevents/leaveComments.html',{},context_instance=RequestContext(request))
 
def submitReview(request):
    if request.method == "POST":    
        reviewer = request.POST.get('reviewer')
        review_txt = request.POST.get('review')
        if review_txt =='':
            return render_to_response('myevents/error.html',{"Empty Review"},context_instance=RequestContext(request))
        else:
            if reviewer == '':
                reviewer = 'anonymous'
            r = review.objects.create(name=reviewer,comment=review_txt)
            json = simplejson.dumps({"success":True})
            return HttpResponse(json, mimetype='application/json')
    else:
        return render_to_response('myevents/leaveComments.html',{},context_instance=RequestContext(request))