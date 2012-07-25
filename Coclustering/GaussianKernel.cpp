#include "GaussianKernel.h"

const float GaussianKernel::sigma = 2.0f;

GaussianKernel::GaussianKernel(std::vector<Sample>* pSampleArray) :
		Kernel(pSampleArray) {
}

GaussianKernel::~GaussianKernel(void) {
}

float GaussianKernel::operator()(int i, int j) const {
	Sample& s1 = mpSampleArray->at(i);
	Sample& s2 = mpSampleArray->at(j);
	Sample difference = s1 - s2;
	float differenceNorm = difference.L2Norm();
	return exp(-1.0f * differenceNorm / sigma);
}
