#include "PlanarObjectTracker.h"

const int PlanarObjectTracker::windowSize = 8;
const int PlanarObjectTracker::searchRange = 32;

PlanarObjectTracker::PlanarObjectTracker(void) {
	mpDetector = cv::Ptr < cv::FeatureDetector
			> (new cv::OrbFeatureDetector(200));
	mpDescriptor = cv::Ptr < cv::DescriptorExtractor
			> (new cv::OrbDescriptorExtractor());
	mpMatcher = cv::Ptr < cv::DescriptorMatcher
			> (new cv::BFMatcher(cv::NORM_HAMMING, true));
	mRVec=cv::Mat::zeros(3,1,CV_64FC1);
	mTVec=cv::Mat::zeros(3,1,CV_64FC1);
	mOnTrack = false;
	mDebugMode = false;
}

PlanarObjectTracker::~PlanarObjectTracker(void) {
}

void PlanarObjectTracker::setIntrinsicMatrix(const cv::Mat& matrix) {
	mIntrinsicMatrix = matrix.clone();
}

void PlanarObjectTracker::setDistCoeffs(const cv::Mat& matrix) {
	mDistCoeffs = matrix.clone();
}

void PlanarObjectTracker::loadTemplate(const std::string& filepath) {
	mTemplateImagePath = filepath;
	mTemplateImage = cv::imread(mTemplateImagePath, 0);
	mpDetector->detect(mTemplateImage, mTemplateKeypointArray, cv::Mat());
	//cv::Mat templateDescriptor;
	//mpDescriptor->compute(mTemplateImage,mTemplateKeypointArray,templateDescriptor);
	mpDescriptor->compute(mTemplateImage, mTemplateKeypointArray,
			mTemplateDescriptor);//CV_8UC1 in mTemplateDescriptor if ORB descriptor.
	// FLANN only accepts floating type
	//templateDescriptor.assignTo(mTemplateDescriptor,CV_32FC1);
	int templateKeypointCount = (int) mTemplateKeypointArray.size();
	// build the kd tree for the descriptor
	//mpTempalateDescriptorIndex=cv::Ptr<cv::flann::Index>(new cv::flann::Index(mTemplateDescriptor,cv::flann::KDTreeIndexParams(2)));
	// initialize object points
	mObjectPoints = cv::Mat(templateKeypointCount, 3, CV_32FC1);
	for (int i = 0; i < templateKeypointCount; ++i) {
		float* ptr = mObjectPoints.ptr<float>(i);
		ptr[0] = mTemplateKeypointArray[i].pt.x;
		ptr[1] = mTemplateKeypointArray[i].pt.y;
		ptr[2] = 0.0f;
	}
	// define template image corners.
	mTemplateImageCorners.clear();
	mTemplateImageCorners.reserve(4);
	mTemplateImageCorners.push_back(cv::Point3f(0.0f, 0.0f, 0.0f));
	mTemplateImageCorners.push_back(
			cv::Point3f((float) mTemplateImage.cols, 0.0f, 0.0f));
	mTemplateImageCorners.push_back(
			cv::Point3f((float) mTemplateImage.cols,
					(float) mTemplateImage.rows, 0.0f));
	mTemplateImageCorners.push_back(
			cv::Point3f(0.0f, (float) mTemplateImage.rows, 0.0f));
}

void PlanarObjectTracker::initTrack(cv::Mat& image) {
	cv::Mat gray;
	if (image.type() != CV_8UC1) {
		cv::cvtColor(image, gray, CV_BGR2GRAY, 1);
	} else {
		gray = image;
	}
	Ticker ticker;
	ticker.start();
	std::vector<cv::KeyPoint> frameKeypointArray;
	cv::Mat frameDescriptor;
	mpDetector->detect(gray, frameKeypointArray, cv::Mat());
	if (frameKeypointArray.empty()) {
		return;
	}
	std::cout<<"detection: "<<ticker.stop()<<std::endl;
	ticker.start();
	//cv::Mat uFrameDescriptor;
	//mpDescriptor->compute(gray,frameKeypointArray,uFrameDescriptor);
	mpDescriptor->compute(gray, frameKeypointArray, frameDescriptor);
	std::cout<<"description: "<<ticker.stop()<<std::endl;
	//uFrameDescriptor.assignTo(frameDescriptor,CV_32FC1);
	// find the homograhpy between the frame and the template.
	std::vector<std::pair<int, int> > matchPairArray;
	cv::Mat h = findHomography(&matchPairArray, frameKeypointArray,
			frameDescriptor);
	int matchCount = (int) matchPairArray.size();
	//std::cout<<matchCount<<std::endl;
	if (h.empty() || matchCount < 10) {
		mOnTrack = false;
		return;
	}
	cv::Mat objectPoints = cv::Mat(matchCount, 1, CV_32FC3);
	cv::Mat imagePoints = cv::Mat(matchCount, 1, CV_32FC2);
	for (int i = 0; i < matchCount; ++i) {
		int objectIndex = matchPairArray[i].first;
		float* objectPtr = objectPoints.ptr<float>(i);
		objectPtr[0] = mTemplateKeypointArray[objectIndex].pt.x;
		objectPtr[1] = mTemplateKeypointArray[objectIndex].pt.y;
		objectPtr[2] = 0.0f;
		int imageIndex = matchPairArray[i].second;
		float* imagePtr = imagePoints.ptr<float>(i);
		imagePtr[0] = frameKeypointArray[imageIndex].pt.x;
		imagePtr[1] = frameKeypointArray[imageIndex].pt.y;
	}
	cv::solvePnP(objectPoints, imagePoints, mIntrinsicMatrix, mDistCoeffs,
			mRVec, mTVec, false, cv::ITERATIVE);
	//solveGaussNewton(objectPoints,imagePoints,mIntrinsicMatrix,mDistCoeffs,mRVec,mTVec);
	mOnTrack = true;
	if (mDebugMode) {
		drawMatches(mTemplateImage, image, mTemplateKeypointArray,
				frameKeypointArray, matchPairArray);
	}
}

cv::Mat PlanarObjectTracker::findHomography(
		std::vector<std::pair<int, int> >* pMatchPairArray,
		const std::vector<cv::KeyPoint>& keypointArray,
		const cv::Mat& descriptor) {
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
	Ticker ticker;
	ticker.start();
	std::vector<cv::DMatch> matches;
	mpMatcher->match(descriptor, mTemplateDescriptor, matches, cv::Mat());
	std::cout << "match: " << ticker.stop() << std::endl;
	std::vector<cv::Point2f> srcPoints;
	std::vector<cv::Point2f> dstPoints;
	int matchCount = (int) matches.size();
	srcPoints.reserve(matchCount);
	dstPoints.reserve(matchCount);
	for (int i = 0; i < matchCount; ++i) {
		srcPoints.push_back(mTemplateKeypointArray[matches[i].trainIdx].pt);
		dstPoints.push_back(keypointArray[matches[i].queryIdx].pt);
	}
	std::vector<uchar> inliers(srcPoints.size(), 0);
	ticker.start();
	//cv::Mat homography = cv::findHomography(srcPoints, dstPoints, CV_RANSAC,
	//		2.0f, inliers);
	GeometricVerifier verifier;
	cv::Mat homography=verifier.findHomography(cv::Mat(srcPoints),cv::Mat(dstPoints),inliers);
	std::cout << "homography: " << ticker.stop() << std::endl;
	int inlierCount = 0;
	for (size_t i = 0; i < inliers.size(); ++i) {
		if (inliers[i] != 0) {
			pMatchPairArray->push_back(
					std::pair<int, int>(matches[i].trainIdx,
							matches[i].queryIdx));
			++inlierCount;
		}
	}
	if (inlierCount > 10) {
		return homography;
	}
	return cv::Mat();

}

void PlanarObjectTracker::track(cv::Mat& image) {
	if (!mOnTrack) {
		return;
	}
	cv::Mat gray;
	if (image.type() != CV_8UC1) {
		cv::cvtColor(image, gray, CV_BGR2GRAY, 1);
	} else {
		gray = image;
	}
	Ticker ticker;
	std::vector<cv::Point2f> candidateImagePoints;
	std::vector<float> objectArray;
	std::vector<float> imageArray;
	objectArray.reserve(mObjectPoints.rows*3);
	imageArray.reserve(mObjectPoints.rows*2);
	cv::projectPoints(mObjectPoints, mRVec, mTVec, mIntrinsicMatrix,
			mDistCoeffs, candidateImagePoints, cv::noArray(), 0);
	//cv::Mat templatePatch(windowSize,windowSize,CV_8UC1);
	//cv::Mat invH=getInverseHomography();


	//ticker.start();
	cv::Mat warpImage = warpTemplateImage(gray.size());
	//std::cout << "warping: " << ticker.stop() << std::endl;
	ticker.start();
	for (size_t i = 0; i < candidateImagePoints.size(); ++i) {
		cv::Point srcPoint((int)(candidateImagePoints[i].x + 0.5f),
				(int)(candidateImagePoints[i].y + 0.5f));
		cv::Point dstPoint;
		
		//bool success=getTemplatePatch(&templatePatch,invH,srcPoint);
		//if(!success){
		//	continue;
		//}
		//cv::Rect targetRect = getImageWindow(gray, srcPoint.x, srcPoint.y,
		//	searchRange);
		//cv::Mat targetPatch = gray(targetRect);
		//float score=match(templatePatch,targetPatch,srcPoint,&dstPoint);
		
		//cv::circle(image, srcPoint, 3, CV_RGB(255, 0, 0), 1, CV_AA, 0);
		float score = match(warpImage, srcPoint, gray, &dstPoint);
		if (score > 0.6f) {
			//update rotation and translation
			float* objectPtr = mObjectPoints.ptr<float>((int)i);
			objectArray.push_back(objectPtr[0]);
			objectArray.push_back(objectPtr[1]);
			objectArray.push_back(objectPtr[2]);
			imageArray.push_back((float) dstPoint.x);
			imageArray.push_back((float) dstPoint.y);
			// draw features
			cv::circle(image,srcPoint,3,CV_RGB(255,0,0),1,CV_AA,0);
			cv::circle(image, dstPoint, 3, CV_RGB(0, 255, 0), 1, CV_AA, 0);
			cv::line(image, srcPoint, dstPoint, CV_RGB(255, 255, 255), 1, CV_AA,
					0);
		}
	}
	std::cout << objectArray.size() / 3 << std::endl;
	std::cout << "matching: " << ticker.stop() << std::endl;
	ticker.start();
	if (objectArray.size() > 120) {
		cv::Mat objectPoints(objectArray, false);
		objectPoints = objectPoints.reshape(3, (int)objectArray.size() / 3);
		cv::Mat imagePoints(imageArray, false);
		imagePoints = imagePoints.reshape(2, (int)imageArray.size() / 2);
		std::cout << "matched points: " << objectPoints.rows << std::endl;
		//cv::solvePnP(objectPoints, imagePoints, mIntrinsicMatrix, mDistCoeffs,
		//		mRVec, mTVec, true, cv::ITERATIVE);	// use the initial guess.
		solveGaussNewton(objectPoints,imagePoints,mIntrinsicMatrix,mDistCoeffs,mRVec,mTVec);
		mOnTrack = true;
	} else {
		mOnTrack = false;
	}
	std::cout << "pnp: " << ticker.stop() << std::endl;
}

bool PlanarObjectTracker::getTemplatePatch(cv::Mat* pTemplatePatch, const cv::Mat& invH, const cv::Point& point){
	double* ptr=(double*)invH.data;
	int halfWindowSize=windowSize/2;
	int i=0;
	int j=0;
	for(int x=-1*halfWindowSize, i=0;x<halfWindowSize;++x,++i){
		for(int y=-1*halfWindowSize, j=0;y<halfWindowSize;++y,++j){
			double du,dv;
			projectPoint(&du,&dv,ptr,(double)point.x+x,(double)point.y+y);
			int u=(int)(du+0.5f);
			int v=(int)(dv+0.5f);
			if(u>0 && u<mTemplateImage.cols && v>0 && v<mTemplateImage.rows){
				pTemplatePatch->at<uchar>(j,i)=mTemplateImage.at<uchar>(v,u);
			}else{
				return false;
			}
		}
	}
	return true;
}

void PlanarObjectTracker::projectPoint(double* pX, double* pY, const double h[9], double x, double y){
	double _x=h[0]*x+h[1]*y+h[2];
	double _y=h[3]*x+h[4]*y+h[5];
	double _z=h[6]*x+h[7]*y+h[8];
	double _invz=1.0f/_z;
	*pX=_x*_invz;
	*pY=_y*_invz;
}

float PlanarObjectTracker::match(const cv::Mat& srcImage,
		const cv::Point& srcPoint, const cv::Mat& dstImage,
		cv::Point* pDstPoint) {
	if (srcPoint.x < 0 || srcPoint.y < 0 || srcPoint.x >= srcImage.cols
			|| srcPoint.y >= srcImage.rows) {
		return 0.0f;
	}
	cv::Rect templateRect = getImageWindow(srcImage, srcPoint.x, srcPoint.y,
			windowSize);
	cv::Rect targetRect = getImageWindow(dstImage, srcPoint.x, srcPoint.y,
			searchRange);
	cv::Mat templateImage = srcImage(templateRect);
	cv::Mat targetImage = dstImage(targetRect);
	// using zncc
	cv::Point maxPoint;
	float maxResponse = zncc(targetImage, templateImage, &maxPoint);
	pDstPoint->x = targetRect.x + maxPoint.x + windowSize / 2;
	pDstPoint->y = targetRect.y + maxPoint.y + windowSize / 2;
	return maxResponse;
}

float PlanarObjectTracker::match(const cv::Mat& templatePatch, const cv::Mat& targetPatch, const cv::Point& srcPoint, cv::Point* pDstPoint){
	cv::Point maxPoint;
	float maxResponse = zncc(targetPatch, templatePatch, &maxPoint);
	pDstPoint->x = srcPoint.x + maxPoint.x;
	pDstPoint->y = srcPoint.y + maxPoint.y;
	return maxResponse;
}

cv::Rect PlanarObjectTracker::getImageWindow(const cv::Mat& image, int x, int y,
		int windowSize) {
	int halfWindowSize = windowSize / 2;
	cv::Rect imageRect(0, 0, image.cols, image.rows);
	cv::Rect windowRect(x - halfWindowSize, y - halfWindowSize, windowSize,
			windowSize);
	cv::Rect intersectRect = imageRect & windowRect;
	return intersectRect;
}

cv::Mat PlanarObjectTracker::getRotationVec() {
	return mRVec;
}

cv::Mat PlanarObjectTracker::getTranslationVec() {
	return mTVec;
}

std::vector<cv::Point2f> PlanarObjectTracker::getProjectedCorners() {
	std::vector<cv::Point2f> corners;
	cv::projectPoints(mTemplateImageCorners, mRVec, mTVec, mIntrinsicMatrix,
			mDistCoeffs, corners, cv::noArray(), 0);
	return corners;
}

void PlanarObjectTracker::drawProjectedCorners(cv::Mat& image) {
	std::vector<cv::Point2f> corners = getProjectedCorners();
	for (size_t i = 0; i < corners.size(); ++i) {
		cv::Point2f& r1 = corners[i % 4];
		cv::Point2f& r2 = corners[(i + 1) % 4];
		cv::line(image, r1, r2, cv::Scalar(255,255,255,255), 2, CV_AA);
	}
}

cv::Mat PlanarObjectTracker::warpTemplateImage(const cv::Size& size) {
	std::vector<cv::Point2f> src;
	src.reserve(4);
	for (int i = 0; i < 4; ++i) {
		src.push_back(
				cv::Point2f(mTemplateImageCorners[i].x,
						mTemplateImageCorners[i].y));
	}
	std::vector<cv::Point2f> dst = getProjectedCorners();
	cv::Mat h = cv::getPerspectiveTransform(src, dst);
	cv::Mat warpImage;
	cv::warpPerspective(mTemplateImage, warpImage, h, size);
	return warpImage;
}

cv::Mat PlanarObjectTracker::getInverseHomography(){
	std::vector<cv::Point2f> dst;
	dst.reserve(4);
	for (int i = 0; i < 4; ++i) {
		dst.push_back(
			cv::Point2f(mTemplateImageCorners[i].x,
			mTemplateImageCorners[i].y));
	}
	std::vector<cv::Point2f> src = getProjectedCorners();
	return cv::getPerspectiveTransform(src, dst);
}

cv::Mat PlanarObjectTracker::getObjectPoints() {
	return mObjectPoints;
}

void PlanarObjectTracker::drawMatches(cv::Mat& image1, cv::Mat& image2,
		const std::vector<cv::KeyPoint>& keypointArray1,
		const std::vector<cv::KeyPoint>& keypointArray2,
		const std::vector<std::pair<int, int> >& matchPairArray) {
	cv::Mat smallImage1;
	ImageResizer::resize(image1, &smallImage1, 80);
	float ratio = (float) smallImage1.rows / (float) image1.rows;
	cv::Rect smallImage1Rect(0, 0, smallImage1.cols, smallImage1.rows);
	cv::Mat smallImage2 = image2(smallImage1Rect);
	smallImage1.copyTo(smallImage2);
	// adjust keypointArray1
	std::vector<cv::KeyPoint> smallKeypointArray1;
	smallKeypointArray1.reserve(keypointArray1.size());
	for (size_t i = 0; i < keypointArray1.size(); ++i) {
		cv::KeyPoint point = keypointArray1[i];
		point.pt.x *= ratio;
		point.pt.y *= ratio;
		smallKeypointArray1.push_back(point);
	}
	for (size_t i = 0; i < matchPairArray.size(); ++i) {
		int index1 = matchPairArray[i].first;
		int index2 = matchPairArray[i].second;
		cv::line(image2, smallKeypointArray1[index1].pt,
				keypointArray2[index2].pt, CV_RGB(255, 255, 255), 1, CV_AA, 0);
	}
}

float PlanarObjectTracker::zncc(const cv::Mat& image,
		const cv::Mat& templateImage, cv::Point* pMaxPoint) {
	if (image.empty() || templateImage.empty()) {
		return 0.0f;
	}
	int templateSum = 0;
	int templateSquareSum = 0;
	for (int i = 0; i < templateImage.rows; ++i) {
		const uchar* ptr = templateImage.ptr < uchar > (i);
		for (int j = 0; j < templateImage.cols; ++j) {
			int val = (int) ptr[j];
			templateSum += val;
			templateSquareSum += val * val;
		}
	}
	// integral image
	int integralSum[searchRange+1][searchRange+1]={0};
	int integralSquareSum[searchRange+1][searchRange+1]={0};
	for(int i=1;i<=image.rows;++i){
		const uchar* imagePtr=image.ptr<uchar>(i-1);
		for(int j=1;j<=image.cols;++j){
			int val=(int)imagePtr[j-1];
			integralSum[i][j]=integralSum[i-1][j]+integralSum[i][j-1]-integralSum[i-1][j-1]+val;
			integralSquareSum[i][j]=integralSquareSum[i-1][j]+integralSquareSum[i][j-1]-integralSquareSum[i-1][j-1]+val*val;
		}
	}
	const int resultRows = searchRange - windowSize + 1;
	const int resultCols = searchRange - windowSize + 1;
	float n = 1.0f / ((float) templateImage.rows * templateImage.cols);
	float scoreArray[resultRows*resultCols];
	for (int y1 = 0; y1 < resultRows; ++y1) {
		for (int x1 = 0; x1 < resultCols; ++x1) {
			int x2 = x1 + templateImage.cols;
			int y2 = y1 + templateImage.rows;
			int locationSum=integralSum[y2][x2]+integralSum[y1][x1]-integralSum[y1][x2]-integralSum[y2][x1];
			int locationSquareSum=integralSquareSum[y2][x2]+integralSquareSum[y1][x1]-integralSquareSum[y1][x2]-integralSquareSum[y2][x1];
			int crossSum = 0;
			for (int i = 0; i < templateImage.rows; ++i) {
				const uchar* templatePtr = templateImage.ptr < uchar > (i);
				const uchar* imagePtr = image.ptr < uchar > (y1 + i);
				for (int j = 0; j < templateImage.cols; ++j) {
					int imageVal = imagePtr[x1 + j];
					crossSum += templatePtr[j] * imageVal;
				}
			}
			float numer = crossSum - (float) templateSum * locationSum * n;
			float denom_a = templateSquareSum
					- (float) templateSum * templateSum * n;
			float denom_b = locationSquareSum
					- (float) locationSum * locationSum * n;
			float denom = denom_a * denom_b;
			float val_sq = (numer * fabsf(numer)) / denom;
			scoreArray[y1 * resultCols + x1] = val_sq;
		}
	}
	float* iter = std::max_element(scoreArray, scoreArray+resultRows*resultCols);
	int index = (int)(iter - scoreArray);
	pMaxPoint->x = index % resultCols;
	pMaxPoint->y = index / resultCols;
	return *iter;
}

double huber_weight(double err_sq)
{
	const double kk = 2.5e-5;
	if (err_sq < kk)
		return 1.f;
	return sqrt(kk / err_sq);
}

double PlanarObjectTracker::solveGaussNewton(const cv::Mat& objectPoints, const cv::Mat& imagePoints, const cv::Mat& cameraMatrix, const cv::Mat& distCoeffs, cv::Mat& rvec, cv::Mat& tvec){
	cv::Mat undistortImagePoints;
	cv::undistortPoints(imagePoints,undistortImagePoints,cameraMatrix,distCoeffs);
	double error=0.0f;
	cv::Mat RMat;
	cv::Rodrigues(rvec,RMat);
	SE3 currentTransform;
	// copy the current rigid transform.
	memcpy(currentTransform.R,RMat.data,9*sizeof(double));
	memcpy(currentTransform.t,tvec.data,3*sizeof(double));
	for(int iteration=0;iteration<2;++iteration){
		// initialize A and b.
		cv::Mat A=cv::Mat::zeros(6,6,CV_64FC1);
		cv::Mat b=cv::Mat::zeros(6,1,CV_64FC1);
		error=0.0f;
		for(int i=0;i<imagePoints.rows;++i){
			const float* objectPtr=objectPoints.ptr<float>(i);
			const float* imagePtr=undistortImagePoints.ptr<float>(i);
			// compute Jacobian
			double x=currentTransform.R[0]*(double)objectPtr[0]+currentTransform.R[1]*(double)objectPtr[1]+currentTransform.R[2]*(double)objectPtr[2]+currentTransform.t[0];
			double y=currentTransform.R[3]*(double)objectPtr[0]+currentTransform.R[4]*(double)objectPtr[1]+currentTransform.R[5]*(double)objectPtr[2]+currentTransform.t[1];
			double invz=1.0f/(currentTransform.R[6]*(double)objectPtr[0]+currentTransform.R[7]*(double)objectPtr[1]+currentTransform.R[8]*(double)objectPtr[2]+currentTransform.t[2]);
			double u=x*invz;
			double v=y*invz;
			double uv=u*v;
			// compute error
			double dx=imagePtr[0]-u;
			double dy=imagePtr[1]-v;
			double err_sq = dx*dx+dy*dy;
			double w = huber_weight(err_sq);
			//double w=1.0f;
			error+= w*err_sq;
			double eArray[2]={dx,dy};
			cv::Mat EMat(2,1,CV_64FC1,eArray);
			double jArray[12]={invz,0.0f,-1.0f*u*invz,-1.0f*uv,1.0f+u*u,-1.0f*v,0.0f,invz,-1.0f*v*invz,-1.0f-v*v,uv,u};
			double jTArray[12]={invz,0.0f,0.0f,invz,-1.0f*u*invz,-1.0f*v*invz,-1.0f*uv,-1.0f-v*v,1.0f+u*u,uv,-1.0f*v,u};
			cv::Mat JMat(2,6,CV_64FC1,jArray);
			cv::Mat JTMat(6,2,CV_64FC1,jTArray);
			A+=JTMat * JMat * w;
			b+=JTMat * EMat * w;
		}
		//std::cout<<"Error: "<<sqrt(error/objectPoints.rows)<<std::endl;
		double updateVArray[6];
		cv::Mat updateVec(6,1,CV_64FC1,updateVArray);
		cv::solve(A,b,updateVec,cv::DECOMP_CHOLESKY);//cholesky is used to solve the equation.
		SE3 updateTransform;
		SE3_exp(updateTransform,updateVArray);
		currentTransform=SE3_mult(updateTransform,currentTransform);
	}
	SE3_rectify(currentTransform);
	// update rvec and tvec;
	memcpy(RMat.data,currentTransform.R,9*sizeof(double));
	cv::Rodrigues(RMat,rvec);
	memcpy(tvec.data,currentTransform.t,3*sizeof(double));
	return sqrt(error/objectPoints.rows);
}
