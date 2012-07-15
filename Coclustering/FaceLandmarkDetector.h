#pragma once
#include <string>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include "flandmark_detector.h"

// this class is used for extracting facial components from the face patch.
class FaceLandmarkDetector {
public:
	static FaceLandmarkDetector* instance();
	// initialize the class from the model file.
	void init(const std::string& filename);
	// this is a wrapper function. detect landmarks and warp the face patch.
	cv::Mat getLandmark(cv::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image, const cv::Rect& bbox);

	// detect facial components using flandmark.
	// bbox is the bounding box obtained from the face detector.
	void detect(std::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image,
			const cv::Rect& bbox);
	// normalize the length of the face patch and modify the landmarks accordingly.
	// the normalized face patch is returned.
	cv::Mat normalize(std::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image,
			const cv::Rect& bbox, const std::vector<cv::Point2f>& landmarkArray);
	// align outer eye corners, mouth corners to predefined positions using the perspective transform.
	// the input image is modified.
	cv::Mat warp(std::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image, const std::vector<cv::Point2f>& landmarkArray);
	// show landmarks for debugging.
	void draw(cv::Mat *pImage,
			const std::vector<cv::Point2f>& landmarkArray,
			const std::string& outputPath = "");
	// print landmarks for debugging.
	void print(const std::vector<cv::Point2f>& landmarkArray);
private:
	FaceLandmarkDetector();
	FaceLandmarkDetector(const FaceLandmarkDetector&);
	FaceLandmarkDetector& operator=(const FaceLandmarkDetector&);
	static FaceLandmarkDetector* pInstance;
	FLANDMARK_Model* mpModel;
	const static int facePatchLength;
	std::vector<cv::Point2f> mBaseLandmarkArray;
};

