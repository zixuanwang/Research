/*
 * IlluminationNormalizer.cpp
 *
 *  Created on: Jul 21, 2012
 *      Author: zixuanwang
 */

#include "IlluminationNormalizer.h"

IlluminationNormalizer::IlluminationNormalizer() {

}

IlluminationNormalizer::~IlluminationNormalizer() {

}

void IlluminationNormalizer::normalize(cv::Mat* pImage, const cv::Mat& image) {
	*pImage = cv::Mat();
	if (image.empty()) {
		return;
	}
	try {
		cv::Mat temp;
		if (image.type() == CV_8UC3) {
			cv::Mat gray;
			cv::cvtColor(image, gray, CV_RGB2GRAY);
			gray.convertTo(temp, CV_32FC1, 1.0 / 255);
		} else {
			image.convertTo(temp, CV_32FC1, 1.0 / 255);
		}
		cv::pow(temp, 0.2, temp);
		//temp.convertTo(*pImage, CV_8UC1, 255.0);
		cv::Mat blurImage1, blurImage2;
		cv::GaussianBlur(temp, blurImage1, cv::Size(0, 0), 1, 1);
		cv::GaussianBlur(temp, blurImage2, cv::Size(0, 0), 2, 2);
		cv::subtract(blurImage1, blurImage2, temp);
		temp.convertTo(*pImage, CV_8UC1, 127, 127);
		cv::equalizeHist(*pImage, *pImage);
	} catch (cv::Exception& e) {
		std::cerr << e.what() << std::endl;
	}
}
