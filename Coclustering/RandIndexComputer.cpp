#include "RandIndexComputer.h"


RandIndexComputer::RandIndexComputer(void)
{
}


RandIndexComputer::~RandIndexComputer(void)
{
}

void RandIndexComputer::loadGroundTruth(const std::string& groundTruthFile) {
	std::ifstream inStream;
	inStream.open(groundTruthFile.c_str());
	if (inStream.good()) {
		std::string line;
		while (getline(inStream, line)) {
			std::vector<std::string> tokenArray;
			boost::split(tokenArray, line, boost::is_any_of("\t"));
			if(!tokenArray.empty()){
				mPatchLabelMap[tokenArray[0]]=tokenArray.back();
			}
		}
		inStream.close();
	}
}

float RandIndexComputer::compute(const boost::unordered_map<std::string, std::string>& patchLabelMap){
	int a = 0;
	int b = 0;
	int n = (int) mPatchLabelMap.size();
	for (boost::unordered_map<std::string, std::string>::iterator iter =
			mPatchLabelMap.begin(); iter != mPatchLabelMap.end(); ++iter) {
		boost::unordered_map<std::string, std::string>::iterator iter2 = iter;
		++iter2;
		for (; iter2 != mPatchLabelMap.end(); ++iter2) {
			if (iter->second == iter2->second && patchLabelMap.at(iter->first)
					== patchLabelMap.at(iter2->first)) {
				++a;
			}
			if (iter->second != iter2->second && patchLabelMap.at(iter->first)
					!= patchLabelMap.at(iter2->first)) {
				++b;
			}
		}
	}
	return (float) 2 * (a + b) / (n * (n - 1));
}

float RandIndexComputer::compute(const std::string& clusterDir) {
	boost::unordered_map<std::string, std::string> patchLabelMap;
	boost::filesystem::directory_iterator end;
	boost::filesystem::directory_iterator iter(clusterDir);
	for (; iter != end; ++iter) {
		boost::filesystem::path bstClusterDir = iter->path();
		boost::filesystem::directory_iterator iter2(bstClusterDir);
		std::string label = bstClusterDir.filename().string();
		for (; iter2 != end; ++iter2) {
			patchLabelMap[iter2->path().filename().string()] = label;
		}
	}
	return compute(patchLabelMap);
}