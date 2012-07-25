#pragma once
#include "Kernel.h"
class LinearKernel: public Kernel {
public:
	LinearKernel(std::vector<Sample>* pSampleArray);
	virtual ~LinearKernel(void);
	// return the inner product of two samples
	virtual float operator()(int i, int j) const;
};

