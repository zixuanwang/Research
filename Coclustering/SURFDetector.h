#pragma once

#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>

class SURFDetector
{
public:
	SURFDetector(int featureCount, int iterations=20);
	~SURFDetector(void);
	void detect(cv::Mat& image, std::vector<cv::KeyPoint>& keypointArray, cv::Mat& mask=cv::Mat());
private:
	int mIterations;
	double mThreshold;
	int mMinFeatureCount;
	int mMaxFeatureCount;
};

