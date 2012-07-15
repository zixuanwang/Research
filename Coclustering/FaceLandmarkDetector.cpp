#include "FaceLandmarkDetector.h"

FaceLandmarkDetector* FaceLandmarkDetector::pInstance = NULL;
const int FaceLandmarkDetector::facePatchLength = 128;

FaceLandmarkDetector::FaceLandmarkDetector() :
		mpModel(NULL) {
	cv::Point2f leftMouth(0.354458f * (float) facePatchLength,
			0.792922f * (float) facePatchLength);
	cv::Point2f rightMouth(0.656528f * (float) facePatchLength,
			0.791711f * (float) facePatchLength);
	cv::Point2f leftEye(0.233760f * (float) facePatchLength,
			0.409634f * (float) facePatchLength);
	cv::Point2f rightEye(0.768109f * (float) facePatchLength,
			0.404784f * (float) facePatchLength);
	mBaseLandmarkArray.push_back(leftMouth);
	mBaseLandmarkArray.push_back(rightMouth);
	mBaseLandmarkArray.push_back(leftEye);
	mBaseLandmarkArray.push_back(rightEye);
}

FaceLandmarkDetector* FaceLandmarkDetector::instance() {
	if (pInstance == NULL) {
		pInstance = new FaceLandmarkDetector;
	}
	return pInstance;
}

void FaceLandmarkDetector::init(const std::string& filename) {
	mpModel = flandmark_init(filename.c_str());
}

cv::Mat FaceLandmarkDetector::getLandmark(cv::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image, const cv::Rect& bbox){
	detect(pLandmarkArray,image,bbox);
	std::vector<cv::Point2f> landmarkArray;
	cv::Mat faceMat=normalize(&landmarkArray,image,bbox,*pLandmarkArray);
	cv::Mat warpedFaceMat=warp(pLandmarkArray,faceMat,landmarkArray);
	pLandmarkArray->erase(pLandmarkArray->begin());// return the first landmark, which the center of the face.
	return warpedFaceMat;
}

void FaceLandmarkDetector::detect(std::vector<cv::Point2f>* pLandmarkArray,
		const cv::Mat& image, const cv::Rect& bbox) {
	pLandmarkArray->clear();
	if (image.type() != CV_8UC1) {
		std::cout << "Error in the image format" << std::endl;
		return;
	}
	int landmarkCount = mpModel->data.options.M;
	float* landmarks = new float[2 * landmarkCount * sizeof(float)];
	IplImage pImage = IplImage(image);
	int box[] = { bbox.x, bbox.y, bbox.x + bbox.width - 1, bbox.y + bbox.height
			- 1 };
	flandmark_detect(&pImage, box, mpModel, landmarks);
	for (int i = 0; i < landmarkCount; ++i) {
		pLandmarkArray->push_back(
				cv::Point2f(landmarks[2 * i], landmarks[2 * i + 1]));
	}
	delete[] landmarks;
}

cv::Mat FaceLandmarkDetector::normalize(
		std::vector<cv::Point2f>* pLandmarkArray, const cv::Mat& image,
		const cv::Rect& bbox, const std::vector<cv::Point2f>& landmarkArray) {
	// normalized landmarks
	pLandmarkArray->clear();
	float widthRatio = (float) facePatchLength / bbox.width;
	float heightRatio = (float) facePatchLength / bbox.height;
	for (size_t i = 0; i < landmarkArray.size(); ++i) {
		const cv::Point2f& point = landmarkArray[i];
		float x = point.x - bbox.x;
		float y = point.y - bbox.y;
		cv::Point2f newPoint(x * widthRatio, y * heightRatio);
		pLandmarkArray->push_back(newPoint);
	}
	// normalize face patch
	cv::Mat faceMat = image(bbox);
	cv::Mat normalizedFaceMat;
	cv::resize(faceMat, normalizedFaceMat,
			cv::Size(facePatchLength, facePatchLength), 0, 0, cv::INTER_LINEAR);
	return normalizedFaceMat;
}

cv::Mat FaceLandmarkDetector::warp(std::vector<cv::Point2f>* pLandmarkArray,
		const cv::Mat& image, const std::vector<cv::Point2f>& landmarkArray) {
	// get four landmarks to register
	std::vector<cv::Point2f> registerLandmarkArray;
	registerLandmarkArray.push_back(landmarkArray[3]);
	registerLandmarkArray.push_back(landmarkArray[4]);
	registerLandmarkArray.push_back(landmarkArray[5]);
	registerLandmarkArray.push_back(landmarkArray[6]);
	// compute the homography to align four landmarks
	cv::Mat H = cv::getPerspectiveTransform(registerLandmarkArray,
			mBaseLandmarkArray);
	// transform all landmarks
	cv::perspectiveTransform(landmarkArray, *pLandmarkArray, H);
	// warp the face image
	cv::Mat warpMat;
	cv::warpPerspective(image, warpMat, H, image.size());
	return warpMat;
}

void FaceLandmarkDetector::draw(cv::Mat *pImage,
		const std::vector<cv::Point2f>& landmarkArray,
		const std::string& outputPath) {
	for (size_t i = 0; i < landmarkArray.size(); ++i) {
		cv::circle(*pImage, landmarkArray[i], 3, CV_RGB(255, 0, 0), 1, CV_AA,
				0);
	}
	if (!outputPath.empty()) {
		cv::imwrite(outputPath, *pImage);
	}
}

void FaceLandmarkDetector::print(
		const std::vector<cv::Point2f>& landmarkArray) {
	for (size_t i = 0; i < landmarkArray.size(); ++i) {
		std::cout << i << "\t<" << landmarkArray[i].x << ", "
				<< landmarkArray[i].y << ">" << std::endl;
	}
}
