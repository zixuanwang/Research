#include "Evaluation.h"


const std::string Evaluation::cascadeName="C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
const std::string Evaluation::nestedCascadeName="C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
const std::string Evaluation::modelPath="C:/flandmark_model.dat";

Evaluation::Evaluation(void)
{
}


Evaluation::~Evaluation(void)
{
}

void Evaluation::split(std::vector<std::string>* pTrainArray, std::vector<std::string>* pTestArray, const std::vector<std::string>& array, float ratio){
	pTrainArray->clear();
	pTestArray->clear();
	if(array.empty() || ratio<0.0f || ratio >1.0f){
		return;
	}
	srand((unsigned int)time(NULL));
	std::set<std::string> trainSet;
	size_t trainSetSize=(size_t)(array.size()*ratio);
	while(trainSet.size()<trainSetSize){
		int index=rand()%array.size();
		trainSet.insert(array[index]);
	}
	std::set<std::string> set(array.begin(),array.end());
	std::set_difference(set.begin(),set.end(),trainSet.begin(),trainSet.end(),std::back_inserter(*pTestArray));
	pTrainArray->assign(trainSet.begin(),trainSet.end());
}

void Evaluation::train(const std::vector<std::string>& trainArray, const std::string& outputPath){
	SVMClassifier svmClassifier;
	// initialize detectors
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	FaceLandmarkDetector::instance()->init(modelPath);
	boost::unordered_map<std::string, int> nameLabelMap;
	for(size_t i=0;i<trainArray.size();++i){
		std::string name=File::getParentDirectory(trainArray[i]);
		if(nameLabelMap.find(name)==nameLabelMap.end()){
			nameLabelMap[name]=nameLabelMap.size();
		}
		cv::Mat image=cv::imread(trainArray[i],0);
		std::vector<cv::Rect> faceArray;
		faceDetector.detect(&faceArray,image);
		if(faceArray.size()==1){
			std::vector<cv::Rect> noseArray;
			noseDetector.detect(&noseArray,image(faceArray[0]));
			if(noseArray.size()==1){
				std::vector<cv::Point2f> landmarkArray;
				cv::Mat faceMat=FaceLandmarkDetector::instance()->getLandmark(&landmarkArray,image,faceArray[0]);
				Sample faceSample=FaceDescriptor::instance()->compute(faceMat,landmarkArray);
				svmClassifier.addSample(faceSample,nameLabelMap[name]);
			}
		}
	}
	svmClassifier.build();
	svmClassifier.save(outputPath);
	Serializer::saveStringMap(nameLabelMap,outputPath+".name");
	Serializer::saveStringArray(trainArray,outputPath+".train");
}

void Evaluation::test(const std::vector<std::string>& testArray, const std::string& inputPath){
	// load classifier
	SVMClassifier classifier;
	classifier.load(inputPath);
	classifier.build();
	boost::unordered_map<std::string, int> nameLabelMap;
	Serializer::loadStringMap(nameLabelMap,inputPath+".name");
	// initialize detectors
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	FaceLandmarkDetector::instance()->init(modelPath);
	float correct=0;
	for(size_t i=0;i<testArray.size();++i){
		std::string testPath=testArray[i];
		cv::Mat image=cv::imread(testPath,0);
		std::vector<cv::Rect> faceArray;
		faceDetector.detect(&faceArray,image);
		if(faceArray.size()==1){
			std::vector<cv::Rect> noseArray;
			noseDetector.detect(&noseArray,image(faceArray[0]));
			if(noseArray.size()==1){
				std::string name=File::getParentDirectory(testPath);
				std::vector<cv::Point2f> landmarkArray;
				cv::Mat faceMat=FaceLandmarkDetector::instance()->getLandmark(&landmarkArray,image,faceArray[0]);
				Sample faceSample=FaceDescriptor::instance()->compute(faceMat,landmarkArray);
				int queryResult=classifier.query(faceSample);
				if(nameLabelMap[name]==queryResult){
					++correct;
				}
			}
		}
	}
	std::cout<<" Accuracy: "<<correct<<"/"<<testArray.size()<<"\t"<<correct/testArray.size()<<std::endl;
}