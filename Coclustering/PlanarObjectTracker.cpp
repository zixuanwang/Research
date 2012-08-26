#include "PlanarObjectTracker.h"


PlanarObjectTracker::PlanarObjectTracker(void)
{
}


PlanarObjectTracker::~PlanarObjectTracker(void)
{
}

void PlanarObjectTracker::calibrateCamera(const std::string& dirPath){
	CameraCalibrator calibrator;
	std::vector<std::string> filelist;
	File::getFiles(&filelist,dirPath);
	calibrator.addChessboardPoints(filelist,cv::Size(9,6));
	calibrator.calibrate(cv::Size(768,432));
	mIntrinsicMatrix=calibrator.getCameraMatrix();
	mDistCoeffs=calibrator.getDistCoeffs();
}

void PlanarObjectTracker::loadTemplate(const std::string& filepath){
	mTemplateImagePath=filepath;
	cv::Mat templateImage=cv::imread(mTemplateImagePath,0);
	mTemplateImageWidth=templateImage.cols;
	mTemplateImageHeight=templateImage.rows;
	cv::Ptr<cv::FeatureDetector> pDetector(new cv::OrbFeatureDetector(200));
	std::vector<cv::KeyPoint> templateKeypointArray;
	pDetector->detect(templateImage,templateKeypointArray,cv::Mat());
	int templateKeypointCount=(int)templateKeypointArray.size();
	mObjectPoints=cv::Mat(templateKeypointCount,3,CV_32FC1);
	for(int i=0;i<templateKeypointCount;++i){
		float* ptr=mObjectPoints.ptr<float>(i);
		ptr[0]=templateKeypointArray[i].pt.x;
		ptr[1]=templateKeypointArray[i].pt.y;
		ptr[2]=0.0f;
	}
}

bool PlanarObjectTracker::initTrack(const cv::Mat& image){
	RobustMatcher matcher;
	cv::Ptr<cv::FeatureDetector> pDetector(new cv::OrbFeatureDetector(200));
	cv::Ptr<cv::DescriptorExtractor> pDescriptor(new cv::OrbDescriptorExtractor());
	matcher.setFeatureDetector(pDetector);
	matcher.setDescriptorExtractor(pDescriptor);
	cv::Mat templateImage=cv::imread(mTemplateImagePath,0);
	std::vector<cv::KeyPoint> templateKeypointArray;
	std::vector<cv::KeyPoint> keypointArray;
	cv::Mat h=matcher.match(templateImage,image,&templateKeypointArray,&keypointArray);
	if(h.empty()){
		return false;
	}
	int templateKeypointCount=(int)templateKeypointArray.size();
	cv::Mat objectPoints=cv::Mat(templateKeypointCount,3,CV_32FC1);
	for(int i=0;i<templateKeypointCount;++i){
		float* ptr=objectPoints.ptr<float>(i);
		ptr[0]=templateKeypointArray[i].pt.x;
		ptr[1]=templateKeypointArray[i].pt.y;
		ptr[2]=0.0f;
	}
	cv::Mat imagePoints=cv::Mat(templateKeypointCount,2,CV_32FC1);
	for(int i=0;i<templateKeypointCount;++i){
		float* ptr=imagePoints.ptr<float>(i);
		ptr[0]=keypointArray[i].pt.x;
		ptr[1]=keypointArray[i].pt.y;
	}
	cv::solvePnP(objectPoints,imagePoints,mIntrinsicMatrix,cv::Mat(),mRVec,mTVec,false,cv::ITERATIVE);
	mLastFrame=image.clone();
	return true;
}

void PlanarObjectTracker::track(const cv::Mat& image){
	std::vector<cv::Point2f> candidateImagePoints;
	std::vector<float> objectArray;
	std::vector<float> imageArray;
	cv::projectPoints(mObjectPoints,mRVec,mTVec,mIntrinsicMatrix,cv::noArray(),candidateImagePoints,cv::noArray(),0);
	for(size_t i=0;i<candidateImagePoints.size();++i){
		cv::Point srcPoint(floor(candidateImagePoints[i].x+0.5f),floor(candidateImagePoints[i].y+0.5f));
		cv::Point dstPoint;
		float score=match(mLastFrame,srcPoint,image,&dstPoint);
		if(score>0.7f){
			//update rotation and translation
			float* objectPtr=mObjectPoints.ptr<float>(i);
			objectArray.push_back(objectPtr[0]);
			objectArray.push_back(objectPtr[1]);
			objectArray.push_back(objectPtr[2]);
			imageArray.push_back(dstPoint.x);
			imageArray.push_back(dstPoint.y);
		}
	}
	if(!objectArray.empty()){
		cv::Mat objectPoints(objectArray,false);
		objectPoints=objectPoints.reshape(0,objectArray.size()/3);
		cv::Mat imagePoints(imageArray,false);
		imagePoints=imagePoints.reshape(0,imageArray.size()/2);
		std::cout<<objectPoints.rows<<std::endl;
		cv::solvePnP(objectPoints,imagePoints,mIntrinsicMatrix,cv::Mat(),mRVec,mTVec,true,cv::ITERATIVE);// use the initial guess.
		mLastFrame=image.clone();
	}
}

float PlanarObjectTracker::match(const cv::Mat& srcImage, const cv::Point& srcPoint, const cv::Mat& dstImage, cv::Point* pDstPoint){
	if(srcPoint.x<0 || srcPoint.y<0 || srcPoint.x>=srcImage.cols || srcPoint.y>=srcImage.rows){
		return 0.0f;
	}
	int windowSize=8;
	int neighborhoodSize=16;
	cv::Rect templateRect=getImageWindow(srcImage,srcPoint.x,srcPoint.y,windowSize);
	cv::Rect targetRect=getImageWindow(dstImage,srcPoint.x,srcPoint.y,neighborhoodSize);
	cv::Mat templateImage=srcImage(templateRect);
	cv::Mat targetImage=dstImage(targetRect);
	cv::Mat matchResult(targetImage.rows-templateImage.rows+1,targetImage.cols-templateImage.cols+1,CV_32FC1);
	cv::matchTemplate(targetImage,templateImage,matchResult,CV_TM_CCOEFF_NORMED);
	double minVal; double maxVal; 
	cv::Point minLoc; 
	cv::Point maxLoc;
	cv::minMaxLoc(matchResult, &minVal, &maxVal, &minLoc, &maxLoc, cv::Mat());
	pDstPoint->x=targetRect.x+maxLoc.x+windowSize/2;
	pDstPoint->y=targetRect.y+maxLoc.y+windowSize/2;
	return (float)maxVal;
}

cv::Rect PlanarObjectTracker::getImageWindow(const cv::Mat& image, int x, int y, int windowSize){
	int halfWindowSize=windowSize/2;
	cv::Rect imageRect(0,0,image.cols,image.rows);
	cv::Rect windowRect(x-halfWindowSize,y-halfWindowSize,windowSize,windowSize);
	cv::Rect intersectRect=imageRect & windowRect;
	return intersectRect;
}

cv::Mat PlanarObjectTracker::getRotationVec(){
	return mRVec;
}

cv::Mat PlanarObjectTracker::getTranslationVec(){
	return mTVec;
}

std::vector<cv::Point2f> PlanarObjectTracker::getProjectedCorners(){
	float objectArray[4][3]={{0.0f,0.0f,0.0f},{(float)mTemplateImageWidth,0.0f,0.0f},{(float)mTemplateImageWidth,(float)mTemplateImageHeight,0.0f},{0.0f,(float)mTemplateImageHeight,0.0f}};
	cv::Mat objectPoints(4,3,CV_32FC1,objectArray);
	std::vector<cv::Point2f> corners;
	cv::projectPoints(objectPoints,mRVec,mTVec,mIntrinsicMatrix,cv::noArray(),corners,cv::noArray(),0);
	return corners;
}
