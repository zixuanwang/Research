/*
 * CascadeDetector.cpp
 *
 *  Created on: Jul 11, 2012
 *      Author: zixuanwang
 */

#include "CascadeDetector.h"

CascadeDetector::CascadeDetector() {

}

CascadeDetector::~CascadeDetector() {
}

void CascadeDetector::init(const std::string& cascadeName) {
	if (!cascadeName.empty()) {
		mCascade.load(cascadeName);
	}
}

void CascadeDetector::detect(std::vector<cv::Rect>* pRectArray,
		const cv::Mat& image) {
	pRectArray->clear();
	if (mCascade.empty() || image.empty()) {
		return;
	}
	if (image.type() != CV_8UC1) {
		std::cout << "Error in the image format" << std::endl;
		return;
	}
	try {
		cv::equalizeHist(image, image);
		mCascade.detectMultiScale(image, *pRectArray, 1.1, 2,
				0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
	} catch (cv::Exception& e) {
		std::cerr << e.what() << std::endl;
	}
}

void CascadeDetector::draw(cv::Mat *pImage,
		const std::vector<cv::Rect>& rectArray, const std::string& outputPath) {
	for (size_t i = 0; i < rectArray.size(); ++i) {
		cv::rectangle(*pImage, rectArray[i], CV_RGB(255,0,0));
	}
	if (!outputPath.empty()) {
		cv::imwrite(outputPath, *pImage);
	}
}
