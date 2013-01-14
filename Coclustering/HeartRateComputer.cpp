/*
 * HeartRateComputer.cpp
 *
 *  Created on: Jan 10, 2013
 *      Author: zxwang
 */

#include "HeartRateComputer.h"

HeartRateComputer::HeartRateComputer() : mFoundFace(false),
		mHeartRate(0.0f), mpFaceDetector(NULL) {

}

HeartRateComputer::~HeartRateComputer() {

}

void HeartRateComputer::setFaceDetector(CascadeDetector* pFaceDetector, CascadeDetector* pNoseDetector) {
	mpFaceDetector = pFaceDetector;
	mpNoseDetector = pNoseDetector;

}

void HeartRateComputer::setFaceBoundingBox(const cv::Rect& faceBoundingBox) {
	mFaceBoundingBox = faceBoundingBox;
}

cv::Rect HeartRateComputer::getFaceBoundingBox() {
	return mFaceBoundingBox;
}

void HeartRateComputer::captureFrame(cv::Mat& frame) {
	if(!mFoundFace){
		mFoundFace = computeFaceBoundingBox(frame);
	}
	if(mFoundFace){
		cv::rectangle(frame, mFaceBoundingBox, cv::Scalar(255, 0, 0, 0), 3, CV_AA,
				0);
	}
	boost::posix_time::ptime timer =
			boost::posix_time::microsec_clock::local_time();
	std::cout << timer.time_of_day().total_milliseconds() << std::endl;
	cv::Mat hsv;
	cv::cvtColor(frame,hsv,CV_BGR2HSV);
	cv::Scalar mean = cv::mean(hsv);
	std::cout << mean.val[0] << std::endl;
}

float HeartRateComputer::getHeartRate() {
	return 0.0f;
}

bool HeartRateComputer::computeFaceBoundingBox(const cv::Mat& frame){
	cv::Mat gray;
	if (frame.type() == CV_8UC1) {
		gray = frame;
	} else {
		cv::cvtColor(frame, gray, CV_BGR2GRAY);
	}
	std::vector<cv::Rect> faceArray;
	mpFaceDetector->detect(&faceArray, gray);
	if(faceArray.size() == 1){
		std::vector<cv::Rect> noseArray;
		mpNoseDetector->detect(&noseArray, gray(faceArray[0]));
		if (noseArray.size() == 1) {
			mFaceBoundingBox = faceArray[0];
			return true;
		}
	}
	return false;
}
