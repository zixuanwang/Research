#include "ImageResizer.h"


ImageResizer::ImageResizer(void)
{
}


ImageResizer::~ImageResizer(void)
{
}

void ImageResizer::crop(const std::string& imagePath,
		const std::string& cropImagePath, int width, int height) {
	cv::Mat image = cv::imread(imagePath);
	cv::Mat cropImage;
	crop(image, &cropImage, width, height);
	cv::imwrite(cropImagePath, cropImage);
}

void ImageResizer::crop(const cv::Mat& src, cv::Mat* pDst, int width,
		int height) {
	*pDst = cv::Mat();
	try {
		if (src.empty() || width < 0 || height < 0) {
			return;
		}
		if (!src.empty() && width == 0 && height > 0) {
			double ratio = (double) height / src.rows;
			cv::resize(src, *pDst, cv::Size(), ratio, ratio, cv::INTER_LINEAR);
		}
		if (!src.empty() && height == 0 && width > 0) {
			double ratio = (double) width / src.cols;
			cv::resize(src, *pDst, cv::Size(), ratio, ratio, cv::INTER_LINEAR);
		}
		if (!src.empty() && width > 0 && height > 0) {
			int rows = src.rows;
			int cols = src.cols;
			double widthRatio = (double) width / cols;
			double heightRatio = (double) height / rows;
			double ratio = widthRatio > heightRatio ? widthRatio : heightRatio;
			cv::Mat resizedImage;
			cv::resize(src, resizedImage, cv::Size(), ratio, ratio,
					cv::INTER_LINEAR);
			int centerX = resizedImage.cols / 2;
			int centerY = resizedImage.rows / 2;
			*pDst = resizedImage(
					cv::Range(centerY - height / 2, centerY + (height + 1) / 2),
					cv::Range(centerX - width / 2, centerX + (width + 1) / 2));
		}
	} catch (cv::Exception& e) {
		std::cerr << e.what() << std::endl;
	}
}

void ImageResizer::resize(const cv::Mat& src, cv::Mat* pDst, int maxLength) {
	*pDst = cv::Mat();
	if (src.empty()) {
		return;
	}
	int rows = src.rows;
	int cols = src.cols;
	int length = rows > cols ? rows : cols;
	double ratio = (double) maxLength / length;
	try {
		cv::resize(src, *pDst, cv::Size(), ratio, ratio, cv::INTER_LINEAR);
	} catch (cv::Exception& e) {
		std::cerr << e.what() << std::endl;
	}
}