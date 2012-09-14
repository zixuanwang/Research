import nltk
import os
import re
from nltk.tokenize.punkt import PunktWordTokenizer

def break_words(line):
	l = line.replace('..',' ')
	#ls = nltk.word_tokenize(l.lower())
	ls = PunktWordTokenizer().tokenize(l.lower())
	return ls


def test_one_file(filename):
	allwords = []
	f = open(filename,'r')
	s = f.read()
	allwords = break_words(s)
	fd = {} 	
	print 'total_words:  %i'%len(allwords)
	for w in allwords:
		try:
			fd[w] = fd[w]+1
		except KeyError:
			fd[w] = 1
	
	print 'distince words: %i'%len(fd.keys())
	for k,v in fd.items():
		print k,v
		

def global_tf(folder):
	files = os.listdir(folder)
	fd = {}
	for fl in files:
		print fl
		path = os.path.join(folder, fl)
		f = open(path,'r')
		s = f.read()
		f.close()
		allwords = break_words(s)
		for word in allwords:
			w = re.sub('\.$','',word)
			w = re.sub('^\.','',w)
			try:
				fd[w] = fd[w]+1
			except KeyError:
				fd[w] = 1

	of  = open('reviews_term_frequence.txt','w')
	for k,v  in fd.items():
		of.write(k+'\t'+str(v)+'\n')
	of.close()

def remove_stop_words(file1,file2,file3,file4):
	orig_wf = open(file1,'r')
	stop_wf = open(file2,'r')
	output_wf = open(file3,'w')
	stop_wof = open(file4, 'w')

	stop_ws = {}
	for line in stop_wf:
		stop_ws[line.strip()] = 1
		print line
	stop_wf.close()

	for line in orig_wf:
		terms = line.strip().split('\t')
		print terms[0]
		if stop_ws.has_key(terms[0]):
			stop_wof.write(line)
		else:
			output_wf.write(line)

			

#test_one_file('yelp_reviews/95')
#global_tf('yelp_reviews/')
remove_stop_words('reviews_term_frequence.txt','stopwords.txt','reviews_tf_remove_stopwords.txt','stopwords_in_reviews.txt')
