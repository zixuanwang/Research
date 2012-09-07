#pragma once

#include <opencv2/opencv.hpp>
#include "GeometricVerifier.h"
#include "ImageResizer.h"
#include "SE3_basic.h"
#include "Ticker.h"

class PlanarObjectTracker {
public:
	PlanarObjectTracker(void);
	~PlanarObjectTracker(void);
	void setIntrinsicMatrix(const cv::Mat& matrix);
	void setDistCoeffs(const cv::Mat& matrix);
	void loadTemplate(const std::string& filepath);
	void initTrack(cv::Mat& image);
	cv::Mat findHomography(std::vector<std::pair<int, int> >* pMatchPairArray,
			const std::vector<cv::KeyPoint>& keypointArray,
			const cv::Mat& descriptor);
	cv::Mat getInverseHomography();
	bool getTemplatePatch(cv::Mat* pTemplatePatch, const cv::Mat& invH, const cv::Point& point);
	void projectPoint(double* pX, double* pY, const double h[9], double x, double y);
	// once the tracking is initialized, this function can be called.
	void track(cv::Mat& image);
	float match(const cv::Mat& srcImage, const cv::Point& srcPoint,
			const cv::Mat& dstImage, cv::Point* pDstPoint);
	float match(const cv::Mat& templatePatch, const cv::Mat& targetPatch, const cv::Point& srcPoint, cv::Point* pDstPoint);
	cv::Rect getImageWindow(const cv::Mat& image, int x, int y, int windowSize);
	cv::Mat getRotationVec();
	cv::Mat getTranslationVec();
	std::vector<cv::Point2f> getProjectedCorners();
	void drawProjectedCorners(cv::Mat& image);
	cv::Mat warpTemplateImage(const cv::Size& size);
	inline bool status() {
		return mOnTrack;
	}
	cv::Mat getObjectPoints();
	inline void enableDebug() {
		mDebugMode = true;
	}
	inline void disableDebug() {
		mDebugMode = false;
	}
	inline bool getDebugMode() {
		return mDebugMode;
	}
	void drawMatches(cv::Mat& image1, cv::Mat& image2,
			const std::vector<cv::KeyPoint>& keypointArray1,
			const std::vector<cv::KeyPoint>& keypointArray2,
			const std::vector<std::pair<int, int> >& matchPairArray);
	// two images must be of type CV_8UC1.
	float zncc(const cv::Mat& image, const cv::Mat& templateImage,
			cv::Point* pMaxPoint);
	double solveGaussNewton(const cv::Mat& objectPoints, const cv::Mat& imagePoints, const cv::Mat& cameraMatrix, const cv::Mat& distCoeffs, cv::Mat& rvec, cv::Mat& tvec);
	void buildPyramid(std::vector<cv::Mat>* pPyramid, const cv::Mat& image, int k);
	cv::Mat selectPyramidImage();
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
	static const int windowSize;
	static const int searchRange;
	std::vector<cv::Mat> mPyramid;
	double mProjectedArea;
	double mTemplateArea;
};

