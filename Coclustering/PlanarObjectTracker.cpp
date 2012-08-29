#include "PlanarObjectTracker.h"


PlanarObjectTracker::PlanarObjectTracker(void)
{
	mpDetector=cv::Ptr<cv::FeatureDetector>(new cv::OrbFeatureDetector(400));
	mpDescriptor=cv::Ptr<cv::DescriptorExtractor>(new cv::OrbDescriptorExtractor());
	//mpDetector=cv::Ptr<SURFDetector>(new SURFDetector(100));
	//mpDescriptor=cv::Ptr<cv::DescriptorExtractor>(new cv::SurfDescriptorExtractor());
	mpMatcher=cv::DescriptorMatcher::create("BruteForce-Hamming(2)");
	mOnTrack=false;
	mDebugMode=false;
}


PlanarObjectTracker::~PlanarObjectTracker(void)
{
}

void PlanarObjectTracker::setIntrinsicMatrix(const cv::Mat& matrix){
	mIntrinsicMatrix=matrix.clone();
}

void PlanarObjectTracker::setDistCoeffs(const cv::Mat& matrix){
	mDistCoeffs=matrix.clone();
}

void PlanarObjectTracker::loadTemplate(const std::string& filepath){
	mTemplateImagePath=filepath;
	mTemplateImage=cv::imread(mTemplateImagePath,0);
	mpDetector->detect(mTemplateImage,mTemplateKeypointArray,cv::Mat());
	//cv::Mat templateDescriptor;
	//mpDescriptor->compute(mTemplateImage,mTemplateKeypointArray,templateDescriptor);
	mpDescriptor->compute(mTemplateImage,mTemplateKeypointArray,mTemplateDescriptor);//CV_8UC1 in mTemplateDescriptor if ORB descriptor.
	// FLANN only accepts floating type
	//templateDescriptor.assignTo(mTemplateDescriptor,CV_32FC1);
	int templateKeypointCount=(int)mTemplateKeypointArray.size();
	// build the kd tree for the descriptor
	//mpTempalateDescriptorIndex=cv::Ptr<cv::flann::Index>(new cv::flann::Index(mTemplateDescriptor,cv::flann::KDTreeIndexParams(2)));
	// initialize object points
	mObjectPoints=cv::Mat(templateKeypointCount,3,CV_32FC1);
	for(int i=0;i<templateKeypointCount;++i){
		float* ptr=mObjectPoints.ptr<float>(i);
		ptr[0]=mTemplateKeypointArray[i].pt.x;
		ptr[1]=mTemplateKeypointArray[i].pt.y;
		ptr[2]=0.0f;
	}
	// define template image corners.
	mTemplateImageCorners.clear();
	mTemplateImageCorners.reserve(4);
	mTemplateImageCorners.push_back(cv::Point3f(0.0f,0.0f,0.0f));
	mTemplateImageCorners.push_back(cv::Point3f((float)mTemplateImage.cols,0.0f,0.0f));
	mTemplateImageCorners.push_back(cv::Point3f((float)mTemplateImage.cols,(float)mTemplateImage.rows,0.0f));
	mTemplateImageCorners.push_back(cv::Point3f(0.0f,(float)mTemplateImage.rows,0.0f));
}

void PlanarObjectTracker::initTrack(cv::Mat& image){
	cv::Mat gray;
	if(image.type()!=CV_8UC1){
		cv::cvtColor(image,gray,CV_BGR2GRAY,1);
	}else{
		gray=image;
	}
	std::vector<cv::KeyPoint> frameKeypointArray;
	cv::Mat frameDescriptor;
	mpDetector->detect(gray,frameKeypointArray,cv::Mat());
	if(frameKeypointArray.empty()){
		return;
	}
	//cv::Mat uFrameDescriptor;
	//mpDescriptor->compute(gray,frameKeypointArray,uFrameDescriptor);
	mpDescriptor->compute(gray,frameKeypointArray,frameDescriptor);
	//uFrameDescriptor.assignTo(frameDescriptor,CV_32FC1);
	// find the homograhpy between the frame and the template.
	std::vector<std::pair<int,int> > matchPairArray;
	cv::Mat h=findHomography(&matchPairArray,frameKeypointArray,frameDescriptor);
	int matchCount=(int)matchPairArray.size();
	//std::cout<<matchCount<<std::endl;
	if(h.empty() || matchCount<20){
		mOnTrack=false;
		return;
	}
	cv::Mat objectPoints=cv::Mat(matchCount,3,CV_32FC1);
	cv::Mat imagePoints=cv::Mat(matchCount,2,CV_32FC1);
	for(int i=0;i<matchCount;++i){
		int objectIndex=matchPairArray[i].first;
		float* objectPtr=objectPoints.ptr<float>(i);
		objectPtr[0]=mTemplateKeypointArray[objectIndex].pt.x;
		objectPtr[1]=mTemplateKeypointArray[objectIndex].pt.y;
		objectPtr[2]=0.0f;
		int imageIndex=matchPairArray[i].second;
		float* imagePtr=imagePoints.ptr<float>(i);
		imagePtr[0]=frameKeypointArray[imageIndex].pt.x;
		imagePtr[1]=frameKeypointArray[imageIndex].pt.y;
	}
	cv::solvePnP(objectPoints,imagePoints,mIntrinsicMatrix,mDistCoeffs,mRVec,mTVec,false,cv::ITERATIVE);
	mOnTrack=true;
	if(mDebugMode){
		drawMatches(mTemplateImage,image,mTemplateKeypointArray,frameKeypointArray,matchPairArray);
	}
}

cv::Mat PlanarObjectTracker::findHomography(std::vector<std::pair<int, int> >* pMatchPairArray, const std::vector<cv::KeyPoint>& keypointArray, const cv::Mat& descriptor){
	//cv::Mat indices;
	//cv::Mat dists;
	////mpTempalateDescriptorIndex->knnSearch(descriptor,indices,dists,1,cv::flann::SearchParams(32));
	//std::vector<cv::Point2f> srcPoints;
	//std::vector<cv::Point2f> dstPoints;
	//srcPoints.reserve(descriptor.rows);
	//dstPoints.reserve(descriptor.rows);
	//for(int i=0;i<descriptor.rows;++i){
	//	int* index=indices.ptr<int>(i);
	//	srcPoints.push_back(mTemplateKeypointArray[*index].pt);
	//	dstPoints.push_back(keypointArray[i].pt);
	//}
	//std::vector<uchar> inliers(descriptor.rows, 0);
	//cv::Mat homography = cv::findHomography(srcPoints, dstPoints, CV_RANSAC, 3.0f, inliers);
	//int inlierCount=0;
	//for(size_t i=0;i<inliers.size();++i){
	//	if(inliers[i]!=0){
	//		int* index=indices.ptr<int>(i);
	//		pMatchPairArray->push_back(std::pair<int,int>(*index,(int)i));
	//		++inlierCount;
	//	}
	//}
	//if(inlierCount>10){
	//	return homography;
	//}
	//return cv::Mat();

	std::vector<cv::DMatch> matches;
	mpMatcher->match(descriptor,mTemplateDescriptor,matches,cv::Mat());
	std::vector<cv::Point2f> srcPoints;
	std::vector<cv::Point2f> dstPoints;
	int matchCount=(int)matches.size();
	srcPoints.reserve(matchCount);
	dstPoints.reserve(matchCount);
	for(int i=0;i<matchCount;++i){
		srcPoints.push_back(mTemplateKeypointArray[matches[i].trainIdx].pt);
		dstPoints.push_back(keypointArray[matches[i].queryIdx].pt);
	}
	std::vector<uchar> inliers(srcPoints.size(), 0);
	cv::Mat homography = cv::findHomography(srcPoints, dstPoints, CV_RANSAC, 2.0f, inliers);
	int inlierCount=0;
	for(size_t i=0;i<inliers.size();++i){
		if(inliers[i]!=0){
			pMatchPairArray->push_back(std::pair<int,int>(matches[i].trainIdx,matches[i].queryIdx));
			++inlierCount;
		}
	}
	if(inlierCount>10){
		return homography;
	}
	return cv::Mat();

}

/*
bool PlanarObjectTracker::initTrack(const cv::Mat& image){
	RobustMatcher matcher;
	//cv::Ptr<cv::FeatureDetector> pDetector(new cv::OrbFeatureDetector(200));
	cv::Ptr<cv::FeatureDetector> pDetector(new cv::DynamicAdaptedFeatureDetector(new cv::SurfAdjuster(2000.0,2.0,16000.0),100,110,1));
	cv::Ptr<cv::DescriptorExtractor> pDescriptor(new cv::SurfDescriptorExtractor());
	matcher.setFeatureDetector(pDetector);
	matcher.setDescriptorExtractor(pDescriptor);
	std::vector<cv::KeyPoint> templateKeypointArray;
	std::vector<cv::KeyPoint> keypointArray;
	cv::Mat h=matcher.match(mTemplateImage,image,&templateKeypointArray,&keypointArray);
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
	//mLastFrame=image.clone();
	return true;
}

*/

void PlanarObjectTracker::track(cv::Mat& image){
	if(!mOnTrack){
		return;
	}
	cv::Mat gray;
	if(image.type()!=CV_8UC1){
		cv::cvtColor(image,gray,CV_BGR2GRAY,1);
	}else{
		gray=image;
	}
	Ticker ticker;
	std::vector<cv::Point2f> candidateImagePoints;
	std::vector<float> objectArray;
	std::vector<float> imageArray;
	ticker.start();
	cv::projectPoints(mObjectPoints,mRVec,mTVec,mIntrinsicMatrix,mDistCoeffs,candidateImagePoints,cv::noArray(),0);
	std::cout<<"projection: "<<ticker.stop()<<std::endl;
	ticker.start();
	cv::Mat warpImage=warpTemplateImage(gray.size());
	std::cout<<"warping: "<<ticker.stop()<<std::endl;
	ticker.start();
	for(size_t i=0;i<candidateImagePoints.size();++i){
		cv::Point srcPoint(floor(candidateImagePoints[i].x+0.5f),floor(candidateImagePoints[i].y+0.5f));
		cv::Point dstPoint;
		float score=match(warpImage,srcPoint,gray,&dstPoint);
		if(score>0.8f){
			//update rotation and translation
			float* objectPtr=mObjectPoints.ptr<float>(i);
			objectArray.push_back(objectPtr[0]);
			objectArray.push_back(objectPtr[1]);
			objectArray.push_back(objectPtr[2]);
			imageArray.push_back((float)dstPoint.x);
			imageArray.push_back((float)dstPoint.y);
			// draw features
			cv::circle(image,srcPoint,3,CV_RGB(255,0,0),1,CV_AA,0);
			cv::circle(image,dstPoint,3,CV_RGB(0,255,0),1,CV_AA,0);
			cv::line(image,srcPoint,dstPoint,CV_RGB(255,255,255),1,CV_AA,0);
		}
	}
	std::cout<<objectArray.size()/3<<std::endl;
	std::cout<<"matching: "<<ticker.stop()<<std::endl;
	ticker.start();
	if(objectArray.size()>120){
		cv::Mat objectPoints(objectArray,false);
		objectPoints=objectPoints.reshape(0,objectArray.size()/3);
		cv::Mat imagePoints(imageArray,false);
		imagePoints=imagePoints.reshape(0,imageArray.size()/2);
		std::cout<<"matched points: "<<objectPoints.rows<<std::endl;
		cv::solvePnP(objectPoints,imagePoints,mIntrinsicMatrix,mDistCoeffs,mRVec,mTVec,true,cv::ITERATIVE);// use the initial guess.
		mOnTrack=true;
	}else{
		mOnTrack=false;
	}
	std::cout<<"pnp: "<<ticker.stop()<<std::endl;
}

float PlanarObjectTracker::match(const cv::Mat& srcImage, const cv::Point& srcPoint, const cv::Mat& dstImage, cv::Point* pDstPoint){
	if(srcPoint.x<0 || srcPoint.y<0 || srcPoint.x>=srcImage.cols || srcPoint.y>=srcImage.rows){
		return 0.0f;
	}
	int windowSize=8;
	int neighborhoodSize=32;
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
	std::vector<cv::Point2f> corners;
	cv::projectPoints(mTemplateImageCorners,mRVec,mTVec,mIntrinsicMatrix,mDistCoeffs,corners,cv::noArray(),0);
	return corners;
}

void PlanarObjectTracker::drawProjectedCorners(cv::Mat& image){
	std::vector<cv::Point2f> corners=getProjectedCorners();
		for(size_t i=0; i<corners.size();++i){
		cv::Point2f& r1=corners[i%4];
		cv::Point2f& r2=corners[(i+1)%4];
		cv::line(image,r1,r2,CV_RGB(255,0,0));
	}
}

cv::Mat PlanarObjectTracker::warpTemplateImage(const cv::Size& size){
	std::vector<cv::Point2f> src;
	src.reserve(4);
	for(int i=0;i<4;++i){
		src.push_back(cv::Point2f(mTemplateImageCorners[i].x,mTemplateImageCorners[i].y));
	}
	std::vector<cv::Point2f> dst=getProjectedCorners();
	cv::Mat h=cv::getPerspectiveTransform(src,dst);
	cv::Mat warpImage;
	cv::warpPerspective(mTemplateImage,warpImage,h,size);
	return warpImage;
}

cv::Mat PlanarObjectTracker::getObjectPoints(){
	return mObjectPoints;
}

void PlanarObjectTracker::drawMatches(cv::Mat& image1, cv::Mat& image2, const std::vector<cv::KeyPoint>& keypointArray1, const std::vector<cv::KeyPoint>& keypointArray2, const std::vector<std::pair<int,int> >& matchPairArray){
	cv::Mat smallImage1;
	ImageResizer::resize(image1,&smallImage1,80);
	float ratio=(float)smallImage1.rows/(float)image1.rows;
	cv::Rect smallImage1Rect(0,0,smallImage1.cols,smallImage1.rows);
	cv::Mat smallImage2=image2(smallImage1Rect);
	smallImage1.copyTo(smallImage2);
	// adjust keypointArray1
	std::vector<cv::KeyPoint> smallKeypointArray1;
	smallKeypointArray1.reserve(keypointArray1.size());
	for(size_t i=0;i<keypointArray1.size();++i){
		cv::KeyPoint point=keypointArray1[i];
		point.pt.x*=ratio;
		point.pt.y*=ratio;
		smallKeypointArray1.push_back(point);
	}
	for(size_t i=0;i<matchPairArray.size();++i){
		int index1=matchPairArray[i].first;
		int index2=matchPairArray[i].second;
		cv::line(image2,smallKeypointArray1[index1].pt,keypointArray2[index2].pt,CV_RGB(255,255,255),1,CV_AA,0);
	}
}