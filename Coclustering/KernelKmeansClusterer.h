#pragma once
#include <boost/unordered_set.hpp>
#include <boost/unordered_map.hpp>
#include <boost/shared_ptr.hpp>
#include <ctime>
#include <cfloat>
#include "Clusterer.h"
#include "LinearKernel.h"
#include "GaussianKernel.h"
#include "RankItem.h"
class KernelKmeansClusterer :
	public Clusterer
{
public:
	KernelKmeansClusterer(int k, int maxIteration);
	virtual ~KernelKmeansClusterer(void);
	// compute the distance from one sample to the cluster center
	// the ids of the samples in the cluster are in the clusterIdSet
	float distanceToCluster(int sampleId, const boost::unordered_set<int>& clusterIdSet, const boost::shared_ptr<Kernel>& pKernel);
	// run the clustering algorithm
	void cluster();
	// initialize the clusters, now using random initialization
	void initialize();
private:
	// the max number of iterations
	int mMaxIteration;
};

