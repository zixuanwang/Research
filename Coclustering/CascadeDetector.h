/*
 * CascadeDetector.h
 *
 *  Created on: Jul 11, 2012
 *      Author: zixuanwang
 */

#ifndef CASCADEDETECTOR_H_
#define CASCADEDETECTOR_H_
#include <opencv2/opencv.hpp>

// this class wraps the cascade classifier in opencv.
class CascadeDetector {
public:
	CascadeDetector();
	~CascadeDetector();
	void init(const std::string& cascadeName);
	// the input image should be single channel.
	void detect(std::vector<cv::Rect>* pRectArray, const cv::Mat& image);
	void draw(cv::Mat* pImage, const std::vector<cv::Rect>& rectArray,
			const std::string& outputPath = "");
private:
	cv::CascadeClassifier mCascade;
};

#endif /* CASCADEDETECTOR_H_ */
