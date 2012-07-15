#pragma once

#include <opencv2/opencv.hpp>
#include <boost/shared_ptr.hpp>
#include "Serializer.h"

class Vocabulary
{
public:
	static Vocabulary* instance();
	// compute cluster centers of samples. now k-means is used.
	void build(const cv::Mat& sampleMat, int clusterCount);
	// find the closest cluster center for each sample and returns the frequency histogram.
	// the returned pVector is not normalized.
	// each sample is stored in one row.
	void quantize(std::vector<float>* pVector, const cv::Mat& descriptor);
	// serialize cluster centers.
	void load(const std::string& vocabularyPath);
	void save(const std::string& vocabularyPath);
private:
	Vocabulary();
	Vocabulary(const Vocabulary&);
	Vocabulary& operator=(const Vocabulary&);
	static Vocabulary* pInstance;
	cv::Mat mMat;
	boost::shared_ptr<cv::flann::Index> mpIndex;
};

