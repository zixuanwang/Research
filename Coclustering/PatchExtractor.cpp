/*
 * PatchExtractor.cpp
 *
 *  Created on: Jul 12, 2012
 *      Author: zixuanwang
 */

#include "PatchExtractor.h"

PatchExtractor::PatchExtractor() {

}

PatchExtractor::~PatchExtractor() {

}

void PatchExtractor::extractEye(cv::Mat* pLeftEye, cv::Mat* pRightEye,
		const cv::Mat& image, const std::vector<cv::Point2f>& landmarkArray) {
	assert(landmarkArray.size()==8);
	int maxLength = 64;
	cv::Rect leftEyeRect = boundingBox(landmarkArray[1], landmarkArray[5]);
	cv::Rect rightEyeRect = boundingBox(landmarkArray[2], landmarkArray[6]);
	cv::Mat leftEyePatch = image(leftEyeRect);
	cv::Mat rightEyePatch = image(rightEyeRect);
	ImageResizer::resize(leftEyePatch, pLeftEye, maxLength);
	ImageResizer::resize(rightEyePatch, pRightEye, maxLength);
}

cv::Rect PatchExtractor::boundingBox(const cv::Point2f& p1,
		const cv::Point2f& p2) {
	float centerX = (p1.x + p2.x) / 2.0f;
	float centerY = (p1.y + p2.y) / 2.0f;
	float width = abs(p1.x - p2.x);
	float height = abs(p1.y - p2.y);
	float length = width > height ? width : height;
	cv::Rect rect(centerX - length / 2, centerY - length / 2, length, length);
	return rect;
}
