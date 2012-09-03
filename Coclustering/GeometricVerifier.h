#pragma once

#include <opencv2/opencv.hpp>
#include <ctime>

class GeometricVerifier
{
public:
	GeometricVerifier(void);
	~GeometricVerifier(void);
	cv::Mat findHomography(const cv::Mat& srcPoints, const cv::Mat& dstPoints, std::vector<uchar>& inliers);
};

