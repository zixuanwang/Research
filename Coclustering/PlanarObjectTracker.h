#pragma once

#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include "RobustMatcher.h"
#include "CameraCalibrator.h"
#include "File.h"
#include "RankItem.h"

class PlanarObjectTracker
{
public:
	PlanarObjectTracker(void);
	~PlanarObjectTracker(void);
	void calibrateCamera(const std::string& dirPath);
	void loadTemplate(const std::string& filepath);
	// return true means tracking is initialized. otherwise return false.
	bool initTrack(const cv::Mat& image);
	// once the tracking is initialized, this function can be called.
	void track(const cv::Mat& image);
	float match(const cv::Mat& srcImage, const cv::Point& srcPoint, const cv::Mat& dstImage, cv::Point* pDstPoint);
	cv::Rect getImageWindow(const cv::Mat& image, int x, int y, int windowSize);
	cv::Mat getRotationVec();
	cv::Mat getTranslationVec();
	std::vector<cv::Point2f> getProjectedCorners();
private:
	cv::Mat mObjectPoints;
	cv::Mat mIntrinsicMatrix;
	cv::Mat mDistCoeffs;
	cv::Mat mRVec;
	cv::Mat mTVec;
	cv::Mat mLastFrame;
	std::string mTemplateImagePath;
	int mTemplateImageWidth;
	int mTemplateImageHeight;
};

