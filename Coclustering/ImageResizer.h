#pragma once
#include <opencv2/opencv.hpp>
#include <string>

class ImageResizer
{
public:
	ImageResizer();
	~ImageResizer();
	static void crop(const std::string& imagePath,
			const std::string& cropImagePath, int width, int height);
	static void crop(const cv::Mat& src, cv::Mat* pDst, int width, int height);
	static void resize(const cv::Mat& src, cv::Mat* pDst, int maxLength);
};

