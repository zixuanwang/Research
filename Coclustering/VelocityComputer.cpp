#include "VelocityComputer.h"


VelocityComputer::VelocityComputer(void)
{
}


VelocityComputer::~VelocityComputer(void)
{
}

float VelocityComputer::compute(uint64_t startTime, uint64_t endTime, const std::vector<cv::KeyPoint>& keypointArray1, const std::vector<cv::KeyPoint>& keypointArray2){
	if(keypointArray1.empty() || keypointArray2.empty()){
		return 0.0f;
	}
	std::vector<float> distanceArray;
	for(size_t i=0;i<keypointArray1.size() && i<keypointArray2.size();++i){
		distanceArray.push_back(offset(keypointArray1[i],keypointArray2[i]));
	}
	size_t n = distanceArray.size() / 2;
    std::nth_element(distanceArray.begin(), distanceArray.begin()+n, distanceArray.end());
	return distanceArray[n]/(float)(endTime-startTime);
}

float VelocityComputer::offset(const cv::KeyPoint& keypoint1, const cv::KeyPoint& keypoint2){
	float distance=0.0f;
	distance+=(keypoint1.pt.x-keypoint2.pt.x)*(keypoint1.pt.x-keypoint2.pt.x);
	distance+=(keypoint1.pt.y-keypoint2.pt.y)*(keypoint1.pt.y-keypoint2.pt.y);
	return sqrt(distance);
}