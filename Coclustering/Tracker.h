#pragma once

#include <opencv2/opencv.hpp>
#include <algorithm>
#include "RankItem.h"
#include "RobustMatcher.h"
class Tracker
{
public:
	Tracker(void);
	~Tracker(void);
	void loadTemplate(const std::string& filepath);
	cv::Mat track(const cv::Mat& image);
	void buildBinMatrix(const std::vector<cv::KeyPoint>& keypointArray, const cv::Size& imageSize);
	// each pair in the returned array is <index in the last frame, index in the current frame>.
	void match(std::vector<cv::Point2f>* pSrcArray, std::vector<cv::Point2f>* pDstArray, const std::vector<cv::KeyPoint>& keypointArray, const cv::Mat& descriptor);
	bool locatePlanarObject(const cv::Mat& objectMat, const cv::Mat& imageMat, const std::vector<cv::Point2f>& srcCornerArray, std::vector<cv::Point2f>* pDstCornerArray);
	cv::Mat getBaseHomography();
	void applyHomograpy(std::vector<cv::Point2f>* pDstArray, const std::vector<cv::Point2f>& srcArray, const cv::Mat& h);
	cv::Mat buildRotationMatrix(float yaw, float pitch, float roll);
private:
	std::vector<cv::KeyPoint> mLastKeyPointArray;
	cv::Mat mLastDescriptor;
	// each entry in this matrix records a list of indices.
	std::vector<std::vector<std::vector<int> > > mBinMatrix;
	cv::Mat mBaseHomography;
	const static int binSize;
};

