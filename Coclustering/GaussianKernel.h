#pragma once
#include "Kernel.h"
class GaussianKernel: public Kernel {
public:
	GaussianKernel(std::vector<Sample>* pSampleArray);
	virtual ~GaussianKernel(void);
	virtual float operator()(int i, int j) const;
private:
	const static float sigma;
};

