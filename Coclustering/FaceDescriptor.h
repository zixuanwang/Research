#pragma once
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include "File.h"
#include "Sample.h"

class FaceDescriptor
{
public:
	static FaceDescriptor* instance();
	// compute a face sample from a given image.
	Sample compute(const cv::Mat& faceImage, const std::vector<cv::Point2f>& landmarkArray);
	Sample compute(const cv::Mat& faceImage, const cv::Point2f& landmark);
private:
	FaceDescriptor();
	FaceDescriptor(const FaceDescriptor&);
	FaceDescriptor& operator=(const FaceDescriptor&);
	static FaceDescriptor* pInstance;
	const static int landmarkPatchLength;
};

