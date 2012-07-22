#include "Evaluation.h"

const std::string Evaluation::cascadeName =
		"/home/zixuanwang/Dropbox/microsoft/haarcascade_frontalface_alt2.xml";
const std::string Evaluation::nestedCascadeName =
		"/home/zixuanwang/Dropbox/microsoft/haarcascade_mcs_nose.xml";
const std::string Evaluation::modelPath =
		"/home/zixuanwang/Dropbox/microsoft/flandmark_model.dat";

Evaluation::Evaluation(void) {
}

Evaluation::~Evaluation(void) {
}

void Evaluation::split(std::vector<std::string>* pTrainArray,
		std::vector<std::string>* pTestArray,
		const std::vector<std::string>& array, float ratio) {
	pTrainArray->clear();
	pTestArray->clear();
	if (array.empty() || ratio < 0.0f || ratio > 1.0f) {
		return;
	}
	std::set<std::string> trainSet;
	size_t trainSetSize = (size_t) (array.size() * ratio);
	while (trainSet.size() < trainSetSize) {
		int index = rand() % array.size();
		trainSet.insert(array[index]);
	}
	std::set<std::string> set(array.begin(), array.end());
	std::set_difference(set.begin(), set.end(), trainSet.begin(),
			trainSet.end(), std::back_inserter(*pTestArray));
	pTrainArray->assign(trainSet.begin(), trainSet.end());
}

std::vector<std::string> Evaluation::faceFilter(const std::string& directory,
		const std::string& filePath) {
	std::vector<std::string> ret;
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	FaceLandmarkDetector::instance()->init(modelPath);

	boost::filesystem::path bstDirectory = directory;
	std::vector<std::string> nameArray;
	Serializer::loadStringArray(nameArray, filePath);
	for (size_t i = 0; i < nameArray.size(); ++i) {
		std::string nameDirectory = (bstDirectory / nameArray[i]).string();
		std::vector<std::string> filenameArray;
		File::getFiles(&filenameArray, nameDirectory);
		for (size_t j = 0; j < filenameArray.size(); ++j) {
			Sample sample = extract(faceDetector, noseDetector,
					filenameArray[j]);
			if (!sample.empty()) {
				ret.push_back(filenameArray[j]);
			}
			std::cout << "Processing " << filenameArray[j] << std::endl;
		}
	}
	return ret;
}

Sample Evaluation::extract(CascadeDetector& faceDetector,
		CascadeDetector& noseDetector, const std::string& imagePath) {
	cv::Mat image = cv::imread(imagePath, 0);
	std::vector<cv::Rect> faceArray;
	faceDetector.detect(&faceArray, image);
	if (faceArray.size() == 1) {
		std::vector<cv::Rect> noseArray;
		noseDetector.detect(&noseArray, image(faceArray[0]));
		if (noseArray.size() == 1) {
			std::vector<cv::Point2f> landmarkArray;
			cv::Mat faceMat = FaceLandmarkDetector::instance()->getLandmark(
					&landmarkArray, image, faceArray[0]);
			return FaceDescriptor::instance()->compute(faceMat, landmarkArray);
		}
	}
	return Sample(0);
}

void Evaluation::train(const std::vector<std::string>& trainArray,
		const std::string& outputPath) {
	SVMClassifier classifier;
	// initialize detectors
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	FaceLandmarkDetector::instance()->init(modelPath);
	boost::unordered_map<std::string, int> nameLabelMap;
	for (size_t i = 0; i < trainArray.size(); ++i) {
		std::string name = File::getParentDirectory(trainArray[i]);
		if (nameLabelMap.find(name) == nameLabelMap.end()) {
			nameLabelMap[name] = nameLabelMap.size();
		}
		Sample faceSample = extract(faceDetector, noseDetector, trainArray[i]);
		if (!faceSample.empty()) {
			classifier.addSample(faceSample, nameLabelMap[name]);
		}
	}
	classifier.build();
	classifier.save(outputPath);
	Serializer::saveStringMap(nameLabelMap, outputPath + ".name");
	Serializer::saveStringArray(trainArray, outputPath + ".train");
}

void Evaluation::test(const std::vector<std::string>& testArray,
		const std::string& inputPath) {
	// load classifier
	SVMClassifier classifier;
	classifier.load(inputPath);
	classifier.build();
	boost::unordered_map<std::string, int> nameLabelMap;
	Serializer::loadStringMap(nameLabelMap, inputPath + ".name");
	// initialize detectors
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	FaceLandmarkDetector::instance()->init(modelPath);
	float correct = 0;
	for (size_t i = 0; i < testArray.size(); ++i) {
		Sample faceSample = extract(faceDetector, noseDetector, testArray[i]);
		if (!faceSample.empty()) {
			std::string name = File::getParentDirectory(testArray[i]);
			// for knn classifier only
//			std::vector<int> resultArray = classifier.query(faceSample, 2);
//			std::vector<int> neighborArray(resultArray.begin() + 1,
//					resultArray.end());
//			int queryResult = classifier.majority(neighborArray);
			int queryResult = classifier.query(faceSample);
			if (nameLabelMap[name] == queryResult) {
				++correct;
			}
		}
	}
	std::cout << " Accuracy: " << correct << "/" << testArray.size() << "\t"
			<< correct / testArray.size() << std::endl;
}
