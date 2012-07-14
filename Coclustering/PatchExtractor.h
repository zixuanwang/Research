/*
 * PatchExtractor.h
 *
 *  Created on: Jul 12, 2012
 *      Author: zixuanwang
 */

#ifndef PATCHEXTRACTOR_H_
#define PATCHEXTRACTOR_H_

#include <opencv2/opencv.hpp>
#include "ImageResizer.h"

class PatchExtractor {
public:
	PatchExtractor();
	~PatchExtractor();
	static void extractEye(cv::Mat* pLeftEye, cv::Mat* pRightEye,
			const cv::Mat& image,
			const std::vector<cv::Point2f>& landmarkArray);
	static cv::Rect boundingBox(const cv::Point2f& p1, const cv::Point2f& p2);
};

#endif /* PATCHEXTRACTOR_H_ */
