#include "CameraCalibrator.h"


CameraCalibrator::CameraCalibrator(void):flag(0),mustInitUndistort(true)
{
}


CameraCalibrator::~CameraCalibrator(void)
{
}

int CameraCalibrator::addChessboardPoints(const std::vector<std::string>& filelist, cv::Size& boardSize){
	std::vector<cv::Point2f> imageCorners;
	std::vector<cv::Point3f> objectCorners;
	for(int i=0;i<boardSize.height;++i){
		for(int j=0;j<boardSize.width;++j){
			objectCorners.push_back(cv::Point3f((float)i,(float)j,0.0f));
		}
	}
	cv::Mat image;
	int successes=0;
	for(size_t i=0;i<filelist.size();++i){
		image=cv::imread(filelist[i],0);
		bool found=cv::findChessboardCorners(image,boardSize,imageCorners);
		cv::cornerSubPix(image,imageCorners,cv::Size(5,5),cv::Size(-1,-1),cv::TermCriteria(cv::TermCriteria::MAX_ITER+cv::TermCriteria::EPS,30,0.1));
		if((int)imageCorners.size()==boardSize.area()){
			addPoints(imageCorners,objectCorners);
			++successes;
		}
	}
	return successes;
}

void CameraCalibrator::addPoints(const std::vector<cv::Point2f>& imageCorners, const std::vector<cv::Point3f>& objectCorners){
	imagePoints.push_back(imageCorners);
	objectPoints.push_back(objectCorners);
}

double CameraCalibrator::calibrate(cv::Size& imageSize){
	mustInitUndistort=true;
	std::vector<cv::Mat> rvecs, tvecs;
	return cv::calibrateCamera(objectPoints,imagePoints,imageSize,cameraMatrix,distCoeffs,rvecs,tvecs,flag);
}

cv::Mat CameraCalibrator::remap(const cv::Mat& image){
	cv::Mat undistorted;
	if(mustInitUndistort){
		cv::initUndistortRectifyMap(cameraMatrix,distCoeffs,cv::Mat(),cv::Mat(),image.size(),CV_32FC1,map1,map2);
		mustInitUndistort=false;
	}
	cv::remap(image,undistorted,map1,map2,cv::INTER_LINEAR);
	return undistorted;
}

cv::Mat CameraCalibrator::getCameraMatrix(){
	return cameraMatrix;
}

cv::Mat CameraCalibrator::getDistCoeffs(){
	return distCoeffs;
}