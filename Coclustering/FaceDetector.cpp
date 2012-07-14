#include "FaceDetector.h"

FaceDetector* FaceDetector::pInstance = NULL;

FaceDetector* FaceDetector::instance() {
	if (pInstance == NULL) {
		pInstance = new FaceDetector;
	}
	return pInstance;
}

FaceDetector::FaceDetector() {
}

void FaceDetector::initNested(const std::string& cascadeName,
		const std::string& nestedCascadeName) {
	if (!cascadeName.empty()) {
		mCascade.load(cascadeName);
	}
	if (!nestedCascadeName.empty()) {
		mNestedCascade.load(nestedCascadeName);
	}
}

void FaceDetector::detect(std::vector<cv::Rect>* pFaceArray,
		const cv::Mat& image) {
	pFaceArray->clear();
	if (mCascade.empty()) {
		return;
	}
	if (image.type() != CV_8UC1) {
		std::cout << "Error in the image format" << std::endl;
		return;
	}
	std::vector<cv::Rect> faceCandidateArray;
	mCascade.detectMultiScale(image, faceCandidateArray, 1.05, 2,
			0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
	for (std::vector<cv::Rect>::const_iterator r = faceCandidateArray.begin();
			r != faceCandidateArray.end(); ++r) {
		cv::Mat smallImgROI;
		std::vector<cv::Rect> nestedObjects;
		if (mNestedCascade.empty()) {
			pFaceArray->push_back(*r);
			continue;
		} else {
			smallImgROI = image(*r);
			mNestedCascade.detectMultiScale(smallImgROI, nestedObjects, 1.1, 2,
					0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
			if (nestedObjects.size() > 0) {
				pFaceArray->push_back(*r);
			}
		}
	}
}

void FaceDetector::draw(cv::Mat *pImage, const std::vector<cv::Rect>& faceArray,
		const std::string& outputPath) {
	for (size_t i = 0; i < faceArray.size(); ++i) {
		cv::rectangle(*pImage, faceArray[i], CV_RGB(255,0,0));
	}
	if (!outputPath.empty()) {
		cv::imwrite(outputPath, *pImage);
	}
}
