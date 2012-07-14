#include "LinearKernel.h"


LinearKernel::LinearKernel(std::vector<Sample>* pSampleArray): Kernel(pSampleArray)
{
}


LinearKernel::~LinearKernel(void)
{
}

float LinearKernel::operator()(int i, int j) const{
	Sample& s1=mpSampleArray->at(i);
	Sample& s2=mpSampleArray->at(j);
	float innerProduct=0.0f;
	size_t sampleSize=s1.size();
	for(size_t i=0;i<sampleSize;++i){
		innerProduct+=s1[i]*s2[i];
	}
	return innerProduct;
}