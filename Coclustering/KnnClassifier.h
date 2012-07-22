#pragma once

#include <boost/shared_ptr.hpp>
#include "Classifier.h"
class KnnClassifier: public Classifier {
public:
	KnnClassifier(void);
	virtual ~KnnClassifier(void);
	// create ann structure for fast nearest neighbor search.
	virtual void build();
	// search k nearest neighbors and the majority is returned.
	virtual int query(const Sample& sample);
	// return k nearest neighbors
	std::vector<int> query(const Sample& sample, int n);
	virtual void save(const std::string& filepath);
	virtual void load(const std::string& filepath);
	int majority(const std::vector<int>& array);
private:
	boost::shared_ptr<cv::flann::Index> mpIndex;
	const static int k;
};

