#include "Vocabulary.h"

Vocabulary* Vocabulary::pInstance = NULL;

Vocabulary::Vocabulary(void)
{
}

Vocabulary* Vocabulary::instance() {
	if (pInstance == NULL) {
		pInstance = new Vocabulary;
	}
	return pInstance;
}

void Vocabulary::build(const cv::Mat& sampleMat, int clusterCount){
	// k-means is temporarily used here
	cv::Mat clusters;
	cv::kmeans(sampleMat, clusterCount, clusters,
		cv::TermCriteria(CV_TERMCRIT_EPS + CV_TERMCRIT_ITER, 50, 1e-6),
		5, cv::KMEANS_PP_CENTERS, mMat);
}
	
void Vocabulary::load(const std::string& vocabularyPath){
	Serializer::load(mMat,vocabularyPath);
	mpIndex.reset(new cv::flann::Index(mMat, cv::flann::KDTreeIndexParams(8)));
}

void Vocabulary::save(const std::string& vocabularyPath){
	Serializer::save(mMat,vocabularyPath);
}

void Vocabulary::quantize(std::vector<float>* pVector, const cv::Mat& descriptor){
	cv::Mat indexMat;
	cv::Mat distanceMat;
	mpIndex->knnSearch(descriptor,indexMat,distanceMat,1,cv::flann::SearchParams(64));
	pVector->assign(mMat.rows,0.0f);
	for(int i=0;i<indexMat.rows;++i){
		int* ptr=indexMat.ptr<int>(i);
		(*pVector)[*ptr]+=1.0f;
	}
}