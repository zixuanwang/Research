#pragma once

#include <opencv2/opencv.hpp>
#include "Sample.h"

class ColorDescriptor
{
public:
	static ColorDescriptor* instance();
	// the input image should have three channels.
	Sample compute(const cv::Mat& image);
private:
	ColorDescriptor();
	ColorDescriptor(const ColorDescriptor&);
	ColorDescriptor& operator=(const ColorDescriptor&);
	static ColorDescriptor* pInstance;
	const static int channelBins;
};

