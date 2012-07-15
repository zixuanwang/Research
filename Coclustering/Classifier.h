#pragma once

#include <opencv2/opencv.hpp>
#include <boost/unordered_map.hpp>
#include "Sample.h"
#include "Serializer.h"

// the abstract class for the classification.
class Classifier
{
public:
	Classifier(void);
	virtual ~Classifier(void);
	// add a training sample to the classifier.
	void addSample(const Sample& sample, int label);
	// build the classifier structure. called after adding samples.
	virtual void build() = 0;
	// query
	virtual int query(const Sample& sample) = 0;
	// serialize the data structures.
	virtual void save(const std::string& filepath);
	virtual void load(const std::string& filepath);
protected:
	int mSampleId;
	std::vector<float> mData;
	cv::Mat mMat;
	boost::unordered_map<int, int> mIdLabelMap;
};

