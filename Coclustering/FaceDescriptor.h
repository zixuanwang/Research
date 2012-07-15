#pragma once
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <iostream>
#include <fstream>
#include <sstream>
#include "Sample.h"

// this class computes the face feature.

class FaceDescriptor
{
public:
	static FaceDescriptor* instance();
	// compute a face sample from the input image.
	// assume only one face appears in the input image.
	Sample compute(const cv::Mat& faceImage, const std::vector<cv::Point2f>& landmarkArray);
	Sample compute(const cv::Mat& faceImage, const cv::Point2f& landmark);
private:
	FaceDescriptor();
	FaceDescriptor(const FaceDescriptor&);
	FaceDescriptor& operator=(const FaceDescriptor&);
	static FaceDescriptor* pInstance;
	const static int landmarkPatchLength;
};

