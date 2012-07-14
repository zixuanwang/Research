#include "Clusterer.h"


Clusterer::Clusterer(int k): mK(k)
{
}


Clusterer::~Clusterer(void)
{
}

void Clusterer::addSample(const Sample& sample, float weight){
	mSampleArray.push_back(sample);
	mWeightArray.push_back(weight);
}

int Clusterer::sampleCount(){
	return (int)mSampleArray.size();
}

Sample Clusterer::sample(size_t index) const{
	if(index<mSampleArray.size()){
		return mSampleArray[index];
	}
	std::cerr<<	"Out of boundary"<<std::endl;
	exit(1);
}

std::vector<int> Clusterer::labelArray() const{
	return mLabelArray;
}