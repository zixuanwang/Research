#pragma once

#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include "BoWDescriptor.h"

class RobustMatcher {
private:
	// pointer to the feature point detector object
	cv::Ptr<cv::FeatureDetector> detector;
	// pointer to the feature descriptor extractor object
	cv::Ptr<cv::DescriptorExtractor> extractor;
	float ratio; // max ratio between 1st and 2nd NN
	double distance; // min distance
public:
	RobustMatcher();
	~RobustMatcher();
	cv::Mat match(const cv::Mat& image1, const cv::Mat& image2,
			std::vector<cv::KeyPoint>* pKeypoint1,
			std::vector<cv::KeyPoint>* pKeypoint2);
	// get the patch containing keypoints
	cv::Mat patch(const cv::Mat& image,
			const std::vector<cv::KeyPoint>& keypointArray);
	void setFeatureDetector(cv::Ptr<cv::FeatureDetector>& detect);
	void setDescriptorExtractor(cv::Ptr<cv::DescriptorExtractor>& desc);
	int ratioTest(std::vector<std::vector<cv::DMatch> > &matches);
	// Insert symmetrical matches in symMatches vector
	void symmetryTest(const std::vector<std::vector<cv::DMatch> >& matches1,
			const std::vector<std::vector<cv::DMatch> >& matches2,
			std::vector<cv::DMatch>& symMatches);
	cv::Mat ransacTest(const std::vector<cv::DMatch>& matches,
			const std::vector<cv::KeyPoint>& keypoints1,
			const std::vector<cv::KeyPoint>& keypoints2,
			std::vector<cv::DMatch>& outMatches);
};

