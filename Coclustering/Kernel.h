#pragma once

#include "Sample.h"
class Kernel
{
public:
	Kernel(std::vector<Sample>* pSampleArray);
	virtual ~Kernel(void);
	virtual float operator()(int i, int j) const = 0;
protected:
	std::vector<Sample>* mpSampleArray;
};

