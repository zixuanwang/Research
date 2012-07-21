#include "ColorDescriptor.h"

ColorDescriptor* ColorDescriptor::pInstance = NULL;
const int ColorDescriptor::channelBins = 8;

ColorDescriptor::ColorDescriptor(void) {
}

ColorDescriptor* ColorDescriptor::instance() {
	if (pInstance == NULL) {
		pInstance = new ColorDescriptor;
	}
	return pInstance;
}

Sample ColorDescriptor::compute(const cv::Mat& image) {
	int histSize[] = { channelBins, channelBins, channelBins };
	float hranges[] = { 0.0, 255.0 };
	const float* ranges[] = { hranges, hranges, hranges };
	int channels[] = { 0, 1, 2 };
	cv::MatND hist;
	cv::calcHist(&image, 1, channels, cv::Mat(), hist, 3, histSize, ranges);
	Sample sample(channelBins * channelBins * channelBins);
	for (int i = 0; i < channelBins; ++i) {
		for (int j = 0; j < channelBins; ++j) {
			for (int k = 0; k < channelBins; ++k) {
				float value = hist.at<float>(i, j, k);
				sample[i * channelBins * channelBins + j * channelBins + k] =
						value;
			}
		}
	}
	sample.normalize();
	return sample;
}
