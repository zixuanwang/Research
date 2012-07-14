#pragma once

#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <boost/shared_ptr.hpp>
#include "Sample.h"
#include "Vocabulary.h"

class BoWDescriptor
{
public:
	static BoWDescriptor* instance();
	Sample compute(const cv::Mat& image);
	// the input image should be single channel.
	void extractDescriptor(std::vector<cv::KeyPoint>* pKeypoint, cv::Mat* pDescriptor, const cv::Mat& image);
private:
	BoWDescriptor();
	BoWDescriptor(const BoWDescriptor&);
	BoWDescriptor& operator=(const BoWDescriptor&);
	static BoWDescriptor* pInstance;
	const static int featurePerImage;
	const static int maxIteration;
	int mMinFeatureCount;
	int mMaxFeatureCount;
};

