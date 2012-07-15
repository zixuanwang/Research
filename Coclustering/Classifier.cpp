#include "Classifier.h"


Classifier::Classifier(void):mSampleId(0)
{
}


Classifier::~Classifier(void)
{
}

void Classifier::addSample(const Sample& sample, int label){
	const std::vector<float>& vector=sample.getData();
	std::copy(vector.begin(),vector.end(),std::back_inserter(mData));
	mIdLabelMap[mSampleId]=label;
	++mSampleId;
}

void Classifier::save(const std::string& filepath){
	if(mMat.empty()){
		mMat=cv::Mat(mData,false);
		mMat=mMat.reshape(0,mSampleId);
	}
	Serializer::save(mMat,filepath+".matrix");
	Serializer::save(mIdLabelMap,filepath+".label");
}

void Classifier::load(const std::string& filepath){
	Serializer::load(mMat,filepath+".matrix");
	Serializer::load(mIdLabelMap,filepath+".label");
}