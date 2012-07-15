#pragma once
#include <string>
#include <vector>
#include <opencv2/opencv.hpp>

// this class is obsolete. use CascadeDetector instead.
class FaceDetector {
public:
	static FaceDetector* instance();
	// load the pre-trained classifier from the file. If the nestedCascade if omitted,
	// only the first classifier will be used.
	void initNested(const std::string& cascadeName, const std::string& nestedCascadeName = "");
	void detect(std::vector<cv::Rect>* pFaceArray, const cv::Mat& image);
	// show landmarks for debugging.
	void draw(cv::Mat* pImage,
			const std::vector<cv::Rect>& faceArray,
			const std::string& outputPath = "");
private:
	FaceDetector();
	FaceDetector(const FaceDetector&);
	FaceDetector& operator=(const FaceDetector&);
	static FaceDetector* pInstance;
	cv::CascadeClassifier mCascade;
	cv::CascadeClassifier mNestedCascade;
};

