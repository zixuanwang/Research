#pragma once

#include <opencv2/opencv.hpp>
#include "Sample.h"
class PCACompressor {
public:
	PCACompressor(void);
	~PCACompressor(void);
	void addSample(const Sample& sample);
	void compress(cv::Mat* pMat, int maxComponents);
private:
	std::vector<float> mData;
	cv::Mat mMat;
	cv::PCA mPCA;
	int mSampleCount;
};

