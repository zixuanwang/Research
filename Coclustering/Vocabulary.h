#pragma once

#include <opencv2/opencv.hpp>
#include <boost/shared_ptr.hpp>
#include "Serializer.h"

class Vocabulary
{
public:
	static Vocabulary* instance();
	void build(const cv::Mat& sampleMat, int clusterCount);
	void load(const std::string& vocabularyPath);
	void save(const std::string& vocabularyPath);
	void quantize(std::vector<float>* pVector, const cv::Mat& descriptor);
private:
	Vocabulary();
	Vocabulary(const Vocabulary&);
	Vocabulary& operator=(const Vocabulary&);
	static Vocabulary* pInstance;
	cv::Mat mMat;
	boost::shared_ptr<cv::flann::Index> mpIndex;
};

