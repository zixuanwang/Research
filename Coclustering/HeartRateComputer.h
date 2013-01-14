/*
 * HeartRateComputer.h
 *
 *  Created on: Jan 10, 2013
 *      Author: zxwang
 */

#ifndef HEARTRATECOMPUTER_H_
#define HEARTRATECOMPUTER_H_
#include <opencv2/opencv.hpp>
#include <boost/date_time.hpp>
#include <iostream>
#include "CascadeDetector.h"

class HeartRateComputer {
public:
	HeartRateComputer();
	~HeartRateComputer();
	void setFaceDetector(CascadeDetector* pFaceDetector, CascadeDetector* pNoseDetector);
	void setFaceBoundingBox(const cv::Rect& faceBoundingBox);
	cv::Rect getFaceBoundingBox();
	void captureFrame(cv::Mat& frame);
	// if the heart rate is computed, non zero value is returned.
	float getHeartRate();
	// if the face bounding box is found, returns true and the rect is stored in mFaceBoundingBox.
	bool computeFaceBoundingBox(const cv::Mat& frame);
private:
	bool mFoundFace;
	float mHeartRate;
	cv::Rect mFaceBoundingBox;
	CascadeDetector* mpFaceDetector;
	CascadeDetector* mpNoseDetector;
};

#endif /* HEARTRATECOMPUTER_H_ */
