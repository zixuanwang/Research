#include "SURFDetector.h"


SURFDetector::SURFDetector(int featureCount, int iterations):mIterations(iterations),mThreshold(1000.0f)
{
	mMinFeatureCount = (int) (0.9f * (float) featureCount);
	mMaxFeatureCount = (int) (1.1f * (float) featureCount);
}


SURFDetector::~SURFDetector(void)
{
}

void SURFDetector::detect(cv::Mat& image, std::vector<cv::KeyPoint>& keypointArray, cv::Mat& mask){
	for (int i = 0; i < mIterations; ++i) {
		cv::Ptr<cv::FeatureDetector> detector = new cv::SurfFeatureDetector(mThreshold);
		keypointArray.clear();
		detector->detect(image, keypointArray,mask);
		int size = (int) keypointArray.size();
		if (size >= mMinFeatureCount && size <= mMaxFeatureCount) {
			break;
		}
		if (size < mMinFeatureCount) {
			mThreshold *= 0.85f;
			if (mThreshold < 1.15f) {
				mThreshold = 1.15f;
			}
		}
		if (size > mMaxFeatureCount) {
			mThreshold *= 1.15f;
		}
	}
}