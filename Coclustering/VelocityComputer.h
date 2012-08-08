#pragma once
#include <opencv2/opencv.hpp>
#include <boost/lexical_cast.hpp>

class VelocityComputer
{
public:
	VelocityComputer(void);
	~VelocityComputer(void);
	float compute(uint64_t startTime, uint64_t endTime, const std::vector<cv::KeyPoint>& keypointArray1, const std::vector<cv::KeyPoint> & keypointArray2);
	float compute(uint64_t startTime, uint64_t endTime, const cv::Mat& homography);
	// return the offset between two key points
	float offset(const cv::KeyPoint& keypoint1, const cv::KeyPoint& keypoint2);
};

