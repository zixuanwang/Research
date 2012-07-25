#include "PCACompressor.h"

PCACompressor::PCACompressor(void) :
		mSampleCount(0) {
}

PCACompressor::~PCACompressor(void) {
}

void PCACompressor::addSample(const Sample& sample) {
	const std::vector<float>& vector = sample.getData();
	std::copy(vector.begin(), vector.end(), std::back_inserter(mData));
	++mSampleCount;
}

void PCACompressor::compress(cv::Mat* pMat, int maxComponents) {
	mMat = cv::Mat(mData, false);
	mMat = mMat.reshape(0, mSampleCount);
	mPCA(mMat, cv::Mat(), CV_PCA_DATA_AS_ROW, maxComponents);
	*pMat = cv::Mat(mMat.rows, maxComponents, mMat.type());
	for (int i = 0; i < mMat.rows; ++i) {
		cv::Mat vec = mMat.row(i);
		cv::Mat coeffs = pMat->row(i);
		mPCA.project(vec, coeffs);
		cv::Mat reconstructed;
		mPCA.backProject(coeffs, reconstructed);
		printf("%d. diff = %g\n", i, norm(vec, reconstructed, cv::NORM_L2));
	}
}
