#pragma once

#include <boost/filesystem.hpp>
#include <boost/unordered_map.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
class RandIndexComputer {
public:
	RandIndexComputer(void);
	~RandIndexComputer(void);
	void loadGroundTruth(const std::string& groundTruthFile);
	float compute(const std::vector<int>& labelArray);
	float compute(
			const boost::unordered_map<std::string, std::string>& patchLabelMap);
	float compute(const std::string& clusterDir);
private:
	boost::unordered_map<std::string, std::string> mPatchLabelMap;
	boost::unordered_map<int, int> mIndexLabelMap;
};

