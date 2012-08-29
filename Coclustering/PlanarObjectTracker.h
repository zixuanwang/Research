#pragma once

#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include "ImageResizer.h"
#include "RankItem.h"
#include "RobustMatcher.h"
#include "SURFDetector.h"
#include "Ticker.h"

class PlanarObjectTracker
{
public:
	PlanarObjectTracker(void);
	~PlanarObjectTracker(void);
	void setIntrinsicMatrix(const cv::Mat& matrix);
	void setDistCoeffs(const cv::Mat& matrix);
	void loadTemplate(const std::string& filepath);
	void initTrack(cv::Mat& image);
	cv::Mat findHomography(std::vector<std::pair<int, int> >* pMatchPairArray, const std::vector<cv::KeyPoint>& keypointArray, const cv::Mat& descriptor);
	// once the tracking is initialized, this function can be called.
	void track(cv::Mat& image);
	float match(const cv::Mat& srcImage, const cv::Point& srcPoint, const cv::Mat& dstImage, cv::Point* pDstPoint);
	cv::Rect getImageWindow(const cv::Mat& image, int x, int y, int windowSize);
	cv::Mat getRotationVec();
	cv::Mat getTranslationVec();
	std::vector<cv::Point2f> getProjectedCorners();
	void drawProjectedCorners(cv::Mat& image);
	cv::Mat warpTemplateImage(const cv::Size& size);
	inline bool status(){return mOnTrack;}
	cv::Mat getObjectPoints();
	inline void enableDebug(){mDebugMode=true;}
	inline void disableDebug(){mDebugMode=false;}
	inline bool getDebugMode(){return mDebugMode;}
	void drawMatches(cv::Mat& image1, cv::Mat& image2, const std::vector<cv::KeyPoint>& keypointArray1, const std::vector<cv::KeyPoint>& keypointArray2,
		const std::vector<std::pair<int,int> >& matchPairArray);
private:
	cv::Mat mObjectPoints;
	cv::Mat mIntrinsicMatrix;
	cv::Mat mDistCoeffs;
	cv::Mat mRVec;
	cv::Mat mTVec;
	cv::Mat mTemplateImage;
	std::vector<cv::KeyPoint> mTemplateKeypointArray;
	cv::Mat mTemplateDescriptor;
	cv::Ptr<cv::flann::Index> mpTempalateDescriptorIndex;
	std::string mTemplateImagePath;
	std::vector<cv::Point3f> mTemplateImageCorners;
	cv::Ptr<cv::FeatureDetector> mpDetector;
	//cv::Ptr<SURFDetector> mpDetector;
	cv::Ptr<cv::DescriptorExtractor> mpDescriptor;
	cv::Ptr<cv::DescriptorMatcher> mpMatcher;
	bool mOnTrack;
	bool mDebugMode;
};

