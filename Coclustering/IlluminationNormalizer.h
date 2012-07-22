/*
 * IlluminationNormalizer.h
 *
 *  Created on: Jul 21, 2012
 *      Author: zixuanwang
 */

#ifndef ILLUMINATIONNORMALIZER_H_
#define ILLUMINATIONNORMALIZER_H_

#include <opencv2/opencv.hpp>

class IlluminationNormalizer {
public:
	IlluminationNormalizer();
	~IlluminationNormalizer();
	static void normalize(cv::Mat* pImage, const cv::Mat& image);
};

#endif /* ILLUMINATIONNORMALIZER_H_ */
