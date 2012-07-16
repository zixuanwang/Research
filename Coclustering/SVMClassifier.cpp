#include "SVMClassifier.h"


SVMClassifier::SVMClassifier(void)
{
}


SVMClassifier::~SVMClassifier(void)
{
}

void SVMClassifier::build(){
	if(mMat.empty()){
		mMat=cv::Mat(mData,false);
		mMat=mMat.reshape(0,mLabelArray.size());
	}
	mParams.svm_type    = CvSVM::C_SVC;
    mParams.kernel_type = CvSVM::LINEAR;
    mParams.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
	std::vector<float> labelArray(mLabelArray.begin(),mLabelArray.end());
	cv::Mat labelMat(labelArray);
	mSVM.train(mMat,labelMat,cv::Mat(),cv::Mat(),mParams);
}

int SVMClassifier::query(const Sample& sample){
	const std::vector<float>& sampleData=sample.getData();
	cv::Mat sampleMat(sampleData);
	sampleMat=sampleMat.reshape(0,1);
	return (int)mSVM.predict(sampleMat);
}

void SVMClassifier::save(const std::string& filepath){
	Classifier::save(filepath);
}

void SVMClassifier::load(const std::string& filepath){
	Classifier::load(filepath);
}