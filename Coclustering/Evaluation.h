#pragma once

#include <opencv2/opencv.hpp>
#include <set>
#include <ctime>
#include "CascadeDetector.h"
#include "FaceDescriptor.h"
#include "FaceLandmarkDetector.h"
#include "KnnClassifier.h"
#include "SVMClassifier.h"
#include "File.h"

// this class wraps routines of doing evaluations.
// you need to change the cascade path and mode path accordingly.
class Evaluation {
public:
	Evaluation(void);
	~Evaluation(void);
	// split the all array to two separate arrays
	// the ratio denotes the trainArray size. array.size()*ratio=trainArray.size()
	static void split(std::vector<std::string>* pTrainArray,
			std::vector<std::string>* pTestArray,
			const std::vector<std::string>& array, float ratio);
	// filter images by the face detector. only images having one face are recorded.
	// each line in the filePath is one person's name.
	static std::vector<std::string> faceFilter(const std::string& directory,
			const std::string& filePath);
	// the wrapper function to extract the face feature from the input file.
	// if exception occurs, the empty sample is returned.
	static Sample extract(CascadeDetector& faceDetector,
			CascadeDetector& noseDetector, const std::string& imagePath);
	static void train(const std::vector<std::string>& trainArray,
			const std::string& outputPath);
	static void test(const std::vector<std::string>& testArray,
			const std::string& inputPath);
private:
	const static std::string cascadeName;
	const static std::string nestedCascadeName;
	const static std::string modelPath;
};

