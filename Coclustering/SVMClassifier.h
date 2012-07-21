#pragma once

#include "Classifier.h"

class SVMClassifier: public Classifier {
public:
	SVMClassifier(void);
	virtual ~SVMClassifier(void);
	// build the classifier structure. called after adding samples.
	virtual void build();
	// query
	virtual int query(const Sample& sample);
	// serialize the data structures.
	virtual void save(const std::string& filepath);
	virtual void load(const std::string& filepath);
private:
	CvSVM mSVM;
	CvSVMParams mParams;
};

