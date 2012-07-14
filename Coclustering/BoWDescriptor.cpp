#include "BoWDescriptor.h"

BoWDescriptor* BoWDescriptor::pInstance = NULL;
const int BoWDescriptor::featurePerImage = 200;
const int BoWDescriptor::maxIteration = 30;

BoWDescriptor::BoWDescriptor(void)
{
	mMinFeatureCount=(int)(0.95f*(float)featurePerImage);
	mMaxFeatureCount=(int)(1.05f*(float)featurePerImage);
}

BoWDescriptor* BoWDescriptor::instance(){
	if (pInstance == NULL) {
		pInstance = new BoWDescriptor;
	}
	return pInstance;
}


Sample BoWDescriptor::compute(const cv::Mat& image){
	cv::Mat descriptor;
	std::vector<cv::KeyPoint> keypoint;
	extractDescriptor(&keypoint, &descriptor,image);
	std::vector<float> sampleArray;
	Vocabulary::instance()->quantize(&sampleArray,descriptor);
	Sample sample(sampleArray);
	sample.normalize();
	return sample;
}

void BoWDescriptor::extractDescriptor(std::vector<cv::KeyPoint>* pKeypoint, cv::Mat* pDescriptor, const cv::Mat& image){
	pKeypoint->clear();
	double threshold=800.0f;
	for(int i=0;i<maxIteration;++i){
		cv::Ptr<cv::FeatureDetector> detector = new cv::SurfFeatureDetector(
			threshold);
		pKeypoint->clear();
		detector->detect(image, *pKeypoint);
		int size = (int) pKeypoint->size();
		if (size >= mMinFeatureCount && size <= mMaxFeatureCount) {
			break;
		}
		if (size < mMinFeatureCount) {
			threshold *= 0.85f;
			if (threshold < 1.15f) {
				threshold = 1.15f;
			}
		}
		if (size > mMaxFeatureCount) {
			threshold *= 1.15f;
		}
	}
	std::cout<<pKeypoint->size()<<" keypoints are detected"<<std::endl;
	// compute the feature descriptor
	// if too many keypoints, only keep first mMaxFeatureCount
	if ((int) pKeypoint->size() > mMaxFeatureCount) {
		pKeypoint->erase(pKeypoint->begin() + mMaxFeatureCount,
				pKeypoint->end());
	}
	cv::Ptr<cv::DescriptorExtractor> extractor =
			new cv::SurfDescriptorExtractor();
	extractor->compute(image, *pKeypoint, *pDescriptor);
}