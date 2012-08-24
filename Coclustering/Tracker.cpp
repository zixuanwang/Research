#include "Tracker.h"

const int Tracker::binSize=8;

Tracker::Tracker(void)
{
}


Tracker::~Tracker(void)
{
}

void Tracker::loadTemplate(const std::string& filepath){
	cv::Mat image=cv::imread(filepath,0);
	cv::ORB orb(50);
	orb(image,cv::Mat(),mLastKeyPointArray,mLastDescriptor,false);
}

cv::Mat Tracker::track(const cv::Mat& image){
	cv::ORB orb(50);
	if(mLastKeyPointArray.empty() || mLastDescriptor.empty()){
		orb(image,cv::Mat(),mLastKeyPointArray,mLastDescriptor,false);
		buildBinMatrix(mLastKeyPointArray,image.size());
		return cv::Mat();
	}else{
		std::vector<cv::KeyPoint> keypointArray;
		cv::Mat descriptor;
		orb(image,cv::Mat(),keypointArray,descriptor,false);
		std::vector<cv::Point2f> srcArray;
		std::vector<cv::Point2f> dstArray;
		match(&srcArray,&dstArray,keypointArray,descriptor);
		std::vector<uchar> inliers(srcArray.size(), 0);
		cv::Mat h=cv::findHomography(srcArray,dstArray,inliers,CV_RANSAC,3);
		mLastKeyPointArray=keypointArray;
		mLastDescriptor=descriptor;
		buildBinMatrix(mLastKeyPointArray,image.size());
		return h;
	}
}

void Tracker::buildBinMatrix(const std::vector<cv::KeyPoint>& keypointArray, const cv::Size& imageSize){
	int binCols=imageSize.width/binSize;
	int binRows=imageSize.height/binSize;
	std::vector<int> dummy;
	std::vector<std::vector<int> > rowDummy(binCols+1,dummy);
	mBinMatrix.assign(binRows+1,rowDummy);
	int keypointArraySize=(int)keypointArray.size();
	for(int i=0;i<keypointArraySize;++i){
		int row=(int)keypointArray[i].pt.y/binSize;
		int col=(int)keypointArray[i].pt.x/binSize;
		for(int rowOffset=-1;rowOffset<=1;++rowOffset){
			for(int colOffset=-1;colOffset<=1;++colOffset){
				int r=row+rowOffset;
				int c=col+colOffset;
				if(r>=0 && c>=0 && r<=binRows && c<=binCols){
					mBinMatrix[r][c].push_back(i);
				}
			}
		}
	}
}

void Tracker::match(std::vector<cv::Point2f>* pSrcArray, std::vector<cv::Point2f>* pDstArray, const std::vector<cv::KeyPoint>& keypointArray, const cv::Mat& descriptor){
	int keypointArraySize=(int)keypointArray.size();
	for(int i=0;i<keypointArraySize;++i){
		cv::Mat rowDescriptor=descriptor.row(i);
		std::vector<RankItem<int,float> > rankList;
		int row=(int)keypointArray[i].pt.y/binSize;
		int col=(int)keypointArray[i].pt.x/binSize;
		std::vector<int>& candidateList=mBinMatrix[row][col];
		for(size_t j=0;j<candidateList.size();++j){
			int index=candidateList[j];
			cv::Mat candidateRowDescriptor=mLastDescriptor.row(index);
			RankItem<int, float> item(index,(float)cv::norm(rowDescriptor,candidateRowDescriptor));
			rankList.push_back(item);
		}
		if(!rankList.empty()){
			pSrcArray->push_back(mLastKeyPointArray[std::min_element(rankList.begin(),rankList.end())->index].pt);
			pDstArray->push_back(keypointArray[i].pt);
		}
	}
}

bool Tracker::locatePlanarObject(const cv::Mat& objectMat, const cv::Mat& imageMat, const std::vector<cv::Point2f>& srcCornerArray, 
		std::vector<cv::Point2f>* pDstCornerArray){
	RobustMatcher matcher;
	cv::Ptr<cv::FeatureDetector> pDetector(new cv::SurfFeatureDetector(1000));
	cv::Ptr<cv::DescriptorExtractor> pDescriptor(new cv::SurfDescriptorExtractor());
	matcher.setFeatureDetector(pDetector);
	matcher.setDescriptorExtractor(pDescriptor);
	std::vector<cv::KeyPoint> objectKeypointArray;
	std::vector<cv::KeyPoint> imageKeypointArray;
	mBaseHomography=matcher.match(objectMat,imageMat,&objectKeypointArray,&imageKeypointArray);
	if(mBaseHomography.empty()){
		return false;
	}
	for(size_t i = 0;i<srcCornerArray.size(); ++i){
        double x = srcCornerArray[i].x;
		double y = srcCornerArray[i].y;
        double Z = 1./(mBaseHomography.at<double>(2,0)*x + mBaseHomography.at<double>(2,1)*y + mBaseHomography.at<double>(2,2));
        double X = (mBaseHomography.at<double>(0,0)*x + mBaseHomography.at<double>(0,1)*y + mBaseHomography.at<double>(0,2))*Z;
        double Y = (mBaseHomography.at<double>(1,0)*x + mBaseHomography.at<double>(1,1)*y + mBaseHomography.at<double>(1,2))*Z;
		pDstCornerArray->push_back(cv::Point2f((float)X,(float)Y));
    }
	return true;
}

cv::Mat Tracker::getBaseHomography(){
	return mBaseHomography;
}

void Tracker::applyHomograpy(std::vector<cv::Point2f>* pDstArray, const std::vector<cv::Point2f>& srcArray, const cv::Mat& h){
	for(size_t i = 0;i<srcArray.size(); ++i){
        double x = srcArray[i].x;
		double y = srcArray[i].y;
        double Z = 1./(h.at<double>(2,0)*x + h.at<double>(2,1)*y + h.at<double>(2,2));
        double X = (h.at<double>(0,0)*x + h.at<double>(0,1)*y + h.at<double>(0,2))*Z;
        double Y = (h.at<double>(1,0)*x + h.at<double>(1,1)*y + h.at<double>(1,2))*Z;
		pDstArray->push_back(cv::Point2f((float)X,(float)Y));
    }
}

cv::Mat Tracker::buildRotationMatrix(float yaw, float pitch, float roll){
	cv::Mat rotation(3,3,CV_32FC1);
	rotation.at<float>(0,0)=cos(yaw)*cos(pitch);
	rotation.at<float>(0,1)=cos(yaw)*sin(pitch)*sin(roll)-sin(yaw)*cos(roll);
	rotation.at<float>(0,2)=cos(yaw)*sin(pitch)*cos(roll)+sin(yaw)*sin(roll);
	rotation.at<float>(1,0)=sin(yaw)*cos(pitch);
	rotation.at<float>(1,1)=sin(yaw)*sin(pitch)*sin(roll)+cos(yaw)*cos(roll);
	rotation.at<float>(1,2)=sin(yaw)*sin(pitch)*cos(roll)-cos(yaw)*sin(roll);
	rotation.at<float>(2,0)=-1.0f*sin(pitch);
	rotation.at<float>(2,1)=cos(pitch)*sin(roll);
	rotation.at<float>(2,2)=cos(pitch)*cos(roll);
	return rotation;
}