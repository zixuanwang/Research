/*
 * HeartRateComputer.cpp
 *
 *  Created on: Jan 10, 2013
 *      Author: zxwang
 */

#include "HeartRateComputer.h"

HeartRateComputer::HeartRateComputer() :
		mHeartRate(0.0f), mpFaceDetector(NULL) {

}

HeartRateComputer::~HeartRateComputer() {

}

void HeartRateComputer::setFaceDetector(CascadeDetector* pFaceDetector) {
	mpFaceDetector = pFaceDetector;
}

void HeartRateComputer::setFaceBoundingBox(const cv::Rect& faceBoundingBox) {
	mFaceBoundingBox = faceBoundingBox;
}

cv::Rect HeartRateComputer::getFaceBoundingBox() {
	return mFaceBoundingBox;
}

void HeartRateComputer::captureFrame(cv::Mat& frame) {
	cv::Mat gray;
	if (frame.type() == CV_8UC1) {
		gray = frame;
	} else {
		cv::cvtColor(frame, gray, CV_BGR2GRAY);
	}
	std::vector<cv::Rect> faceArray;
	mpFaceDetector->detect(&faceArray, gray);
	// show the bounding box for debugging
	if (faceArray.size() == 1) {
		cv::rectangle(frame, faceArray[0], cv::Scalar(255, 0, 0, 0), 3, CV_AA,
				0);
	}
	boost::posix_time::ptime timer =
			boost::posix_time::microsec_clock::local_time();
	std::cout << timer.time_of_day().total_milliseconds() << std::endl;
}

float HeartRateComputer::getHeartRate() {
	return 0.0f;
}
