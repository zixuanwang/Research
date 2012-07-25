#include "KnnClassifier.h"

const int KnnClassifier::k = 9;

KnnClassifier::KnnClassifier(void) {
}

KnnClassifier::~KnnClassifier(void) {
}

void KnnClassifier::build() {
	if (mData.empty()) {
		return;
	}
	if (mMat.empty()) {
		mMat = cv::Mat(mData, false);
		mMat = mMat.reshape(0, mLabelArray.size());
	}
	mpIndex.reset(new cv::flann::Index(mMat, cv::flann::KDTreeIndexParams(8)));
}

int KnnClassifier::query(const Sample& sample) {
	return majority(query(sample, k));
}

std::vector<int> KnnClassifier::query(const Sample& sample, int n) {
	std::vector<int> indices(n);
	std::vector<float> dists(n);
	mpIndex->knnSearch(sample.getData(), indices, dists, n,
			cv::flann::SearchParams(64));
	std::vector<int> labelArray;
	labelArray.reserve(n);
	for (int i = 0; i < n; ++i) {
		labelArray.push_back(mLabelArray[indices[i]]);
	}
	return labelArray;
}

int KnnClassifier::majority(const std::vector<int>& array) {
	int maxCount = 0;
	int entry = -1;
	for (size_t i = 0; i < array.size(); ++i) {
		int count = (int) std::count(array.begin(), array.end(), array[i]);
		if (count > maxCount) {
			maxCount = count;
			entry = array[i];
		}
	}
	return entry;
}

void KnnClassifier::save(const std::string& filepath) {
	Classifier::save(filepath);
	if (mpIndex.get() != NULL) {
		mpIndex->save(filepath + ".index");
	}
}

void KnnClassifier::load(const std::string& filepath) {
	Classifier::load(filepath);
	if (!mMat.empty()) {
		mpIndex.reset(
				new cv::flann::Index(mMat,
						cv::flann::SavedIndexParams(filepath + ".index")));
	}
}
