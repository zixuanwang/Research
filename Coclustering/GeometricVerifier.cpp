#include "GeometricVerifier.h"


GeometricVerifier::GeometricVerifier(void)
{
}


GeometricVerifier::~GeometricVerifier(void)
{
}

cv::Mat GeometricVerifier::findHomography(const cv::Mat& srcPoints, const cv::Mat& dstPoints, std::vector<uchar>& inliers){
	int count=srcPoints.rows;
	inliers.assign(count,0);
	if(count<4){
		return cv::Mat();
	}
	std::vector<uchar> _inliers(count,0);
	srand(time(NULL));
	float thresholdSquare=4.0f;
	std::vector<int> indexArray(count,0);
	for(int i=1;i<count;++i){
		indexArray[i]=i;
	}
	float* srcPtr=(float*)srcPoints.data;
	float* dstPtr=(float*)dstPoints.data;
	CvPoint2D32f srcArray[4];
	CvPoint2D32f dstArray[4];
	double modelArray[9];
	double bestModelArray[9];
	CvMat modelMat=cvMat(3,3,CV_64FC1,modelArray);
	CvMat bestModelMat=cvMat(3,3,CV_64FC1,bestModelArray);
	int bestSupport=0;
	for(int iteration=0;iteration<1000;++iteration){
		int support=0;
		_inliers.assign(count,0);
		for(int i=0;i<4;++i){
			std::swap(indexArray[i],indexArray[rand()%count]);
		}
		for(int i=0;i<4;++i){
			int index=indexArray[i];
			const float* srcRowPtr=srcPoints.ptr<float>(index);
			const float* dstRowPtr=dstPoints.ptr<float>(index);
			srcArray[i].x=srcRowPtr[0];
			srcArray[i].y=srcRowPtr[1];
			dstArray[i].x=dstRowPtr[0];
			dstArray[i].y=dstRowPtr[1];
		}
		cvGetPerspectiveTransform(srcArray,dstArray,&modelMat);
		for(int i=0;i<count;++i){
			int ii=2*i;
			float srcX=srcPtr[ii];
			float srcY=srcPtr[ii+1];
			float dstX=dstPtr[ii];
			float dstY=dstPtr[ii+1];
			float _x=(float)modelArray[0]*srcX+(float)modelArray[1]*srcY+(float)modelArray[2];
			float _y=(float)modelArray[3]*srcX+(float)modelArray[4]*srcY+(float)modelArray[5];
			float _z=(float)modelArray[6]*srcX+(float)modelArray[7]*srcY+(float)modelArray[8];
			float _invz=1.0f/_z;
			float u=_x*_invz;
			float v=_y*_invz;
			float dx=u-dstX;
			float dy=v-dstY;
			if(dx*dx+dy*dy<thresholdSquare){
				_inliers[i]=1;
				++support;
			}
		}
		if((float)support>(float)count*0.1f){
			if(support>bestSupport){
				bestSupport=support;
				memcpy(bestModelArray,modelArray,sizeof(double)*9);
				inliers.assign(_inliers.begin(),_inliers.end());
			}
		}
	}
	if((float)bestSupport>(float)count*0.1f){
		cv::Mat model(3,3,CV_64FC1,bestModelArray);
		if(fabs(cv::determinant(model))>1e-3){
			return model.clone();
		}else{
			return cv::Mat();	
		}

	}
	inliers.assign(count,0);
	return cv::Mat();
}