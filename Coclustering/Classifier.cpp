#include "Classifier.h"


Classifier::Classifier(void)
{
}


Classifier::~Classifier(void)
{
}

void Classifier::addSample(const Sample& sample, int label){
	if(sample.empty()){
		return;
	}
	const std::vector<float>& vector=sample.getData();
	std::copy(vector.begin(),vector.end(),std::back_inserter(mData));
	mLabelArray.push_back(label);
}

void Classifier::save(const std::string& filepath){
	Serializer::save(mMat,filepath+".matrix");
	Serializer::save(mLabelArray,filepath+".label");
}

void Classifier::load(const std::string& filepath){
	Serializer::load(mMat,filepath+".matrix");
	Serializer::load(mLabelArray,filepath+".label");
}