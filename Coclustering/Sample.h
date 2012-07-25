#pragma once

#include <vector>
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <sstream>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>

// we store both location and face features in this class.
// each sample is a feature vector in high dimensional space.
class Sample {
public:
	Sample(void);
	Sample(size_t dimension);
	Sample(const std::vector<float>& vector);
	virtual ~Sample(void);
	Sample operator+(const Sample& rhs) const;
	Sample operator-(const Sample& rhs) const;
	void operator*(float scale);
	float operator[](size_t index) const;
	float& operator[](size_t index);
	// test whether the sample is empty
	bool empty() const;
	// the dimension of the feauture vector.
	size_t size() const;
	// compute the L2 norm.
	float L2Norm();
	// normalize the L2 norm to 1.
	void normalize();
	// print out the sample for debugging.
	void print();
	// get the data of the sample.
	const std::vector<float>& getData() const;
	// save to string
	void save(std::string* pString);
	// load from string
	void load(const std::string& string);
protected:
	std::vector<float> mVector;
};

