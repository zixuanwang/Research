#include "FaceDescriptor.h"

FaceDescriptor* FaceDescriptor::pInstance = NULL;
const int FaceDescriptor::landmarkPatchLength = 4;

FaceDescriptor* FaceDescriptor::instance() {
	if (pInstance == NULL) {
		pInstance = new FaceDescriptor;
	}
	return pInstance;
}

FaceDescriptor::FaceDescriptor() {

}

Sample FaceDescriptor::compute(const cv::Mat& faceImage,
		const std::vector<cv::Point2f>& landmarkArray) {
	std::vector<float> faceArray;
	for (size_t i = 0; i < landmarkArray.size(); ++i) {
		Sample sample = compute(faceImage, landmarkArray[i]);
		const std::vector<float>& sampleData = sample.getData();
		std::copy(sampleData.begin(), sampleData.end(),
				std::back_inserter(faceArray));
	}
	if (faceArray.empty()) {
		return Sample();
	}
	Sample faceSample(faceArray);
	faceSample.normalize();
	return faceSample;
}

Sample FaceDescriptor::compute(const cv::Mat& faceImage,
		const cv::Point2f& landmark) {
	// make the face image illumination invariant.
	cv::Mat image = faceImage;
	IlluminationNormalizer::normalize(&image,faceImage);
	// describe the keypoint by 2 different scales
	std::vector<cv::KeyPoint> keypointArray;
	float scale = 1.0f;
	for (int i = 0; i < 2; ++i) {
		cv::KeyPoint keypoint(landmark, (float) landmarkPatchLength * scale,
				0.0f);
		keypointArray.push_back(keypoint);
		scale *= 2.0f;
	}
	cv::Mat descriptor;
	cv::SIFT sift;
	sift(image, cv::Mat(), keypointArray, descriptor, true);
	std::vector<float> descriptorArray(descriptor.ptr<float>(0),
			descriptor.ptr<float>(0) + descriptor.rows * descriptor.cols);
	Sample faceSample(descriptorArray);
	faceSample.normalize();
	return faceSample;
}
