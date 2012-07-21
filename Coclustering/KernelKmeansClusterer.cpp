#include "KernelKmeansClusterer.h"

KernelKmeansClusterer::KernelKmeansClusterer(int k, int maxIteration) :
		Clusterer(k), mMaxIteration(maxIteration) {
}

KernelKmeansClusterer::~KernelKmeansClusterer(void) {
}

float KernelKmeansClusterer::distanceToCluster(int sampleId,
		const boost::unordered_set<int>& clusterIdSet,
		const boost::shared_ptr<Kernel>& pKernel) {
	if (clusterIdSet.empty()) {
		return FLT_MAX;
	}
	// the sum of weight of the cluster
	float weightSum = 0.0f;
	// the sum of kernels from the sample to all samples in the cluster, multiplied by the weight
	float kernelSum = 0.0f;
	// the sum of kernels from each pair of samples in the cluster, multiplied by weights
	float kernelPairSum = 0.0f;
	for (boost::unordered_set<int>::const_iterator iter = clusterIdSet.begin();
			iter != clusterIdSet.end(); ++iter) {
		float weight = mWeightArray[*iter];
		weightSum += weight;
		float kernelResult = (*pKernel)(sampleId, *iter);
		kernelSum += weight * kernelResult;
		for (boost::unordered_set<int>::const_iterator _iter =
				clusterIdSet.begin(); _iter != clusterIdSet.end(); ++_iter) {
			float _kernelResult = (*pKernel)(*iter, *_iter);
			kernelPairSum += weight * mWeightArray[*_iter] * _kernelResult;
		}
	}
	float kernelSelf = (*pKernel)(sampleId, sampleId);
	if (weightSum == 0.0f) {
		return FLT_MAX;
	}
	return kernelSelf - 2 * kernelSum / weightSum
			+ kernelPairSum / (weightSum * weightSum);
}

void KernelKmeansClusterer::cluster() {
	// define the kernel
	boost::shared_ptr<Kernel> pKernel(new LinearKernel(&mSampleArray));
	int sampleCount = (int) mSampleArray.size();
	// each pair is <clusterLabel, clusterIdSet>
	boost::unordered_map<int, boost::unordered_set<int> > clusterIdSetMap;
	for (int i = 0; i < sampleCount; ++i) {
		clusterIdSetMap[mLabelArray[i]].insert(i);
	}
	for (int iter = 0; iter < mMaxIteration; ++iter) {
		bool change = false;
		for (int i = 0; i < sampleCount; ++i) {
			std::vector<RankItem<int, float> > rankList;
			rankList.reserve(mK);
			for (int j = 0; j < mK; ++j) {
				float distance = distanceToCluster(i, clusterIdSetMap[j],
						pKernel);
				RankItem<int, float> item(j, distance);
				rankList.push_back(item);
			}
			int oldLabel = mLabelArray[i];
			int newLabel =
					std::min_element(rankList.begin(), rankList.end())->index;
			if (oldLabel != newLabel) {
				clusterIdSetMap[oldLabel].erase(i);
				clusterIdSetMap[newLabel].insert(i);
				mLabelArray[i] = newLabel;
				change = true;
			}
		}
		if (!change) {
			break;
		}
	}
}

void KernelKmeansClusterer::initialize() {
	srand((unsigned int) time(NULL));
	mLabelArray.clear();
	mLabelArray.reserve(mSampleArray.size());
	for (size_t i = 0; i < mSampleArray.size(); ++i) {
		mLabelArray.push_back(rand() % mK);
	}
}
