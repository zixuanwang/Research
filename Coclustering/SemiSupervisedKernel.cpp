#include "SemiSupervisedKernel.h"

const float SemiSupervisedKernel::mustLinkWeight = 1.0f;
const float SemiSupervisedKernel::cannotLinkWeight = -1.0f;

SemiSupervisedKernel::SemiSupervisedKernel(std::vector<Sample>* pSampleArray) : LinearKernel(pSampleArray),
		mMustLinkGraph(pSampleArray->size()) {
}

SemiSupervisedKernel::~SemiSupervisedKernel(void) {
}

float SemiSupervisedKernel::operator()(int i, int j) const {
	float similarity = LinearKernel::operator()(i,j);
	float penalty = 0.0f;
	std::pair<int, int> p(i, j);
	if (j < i) {
		p = std::make_pair(j, i);
	}
	if (mMustLinkSet.find(p) != mMustLinkSet.end()) {
		penalty += mustLinkWeight;
	}
	if (mCannotLinkSet.find(p) != mCannotLinkSet.end()) {
		penalty += cannotLinkWeight;
	}
	if (mPossibleLinkMap.find(p) != mPossibleLinkMap.end()){
		penalty += mPossibleLinkMap.at(p);
	}
	return similarity + penalty;
}

void SemiSupervisedKernel::addMustLink(int i, int j) {
	EdgeDesc ed;
	bool success;
	tie(ed, success) = add_edge((VertexDesc) i, (VertexDesc) j, mMustLinkGraph);
}

void SemiSupervisedKernel::addCannotLink(int i, int j) {
	std::pair<int, int> p(i, j);
	if (j < i) {
		p = std::make_pair(j, i);
	}
	mCannotLinkSet.insert(p);
}

void SemiSupervisedKernel::addPossibleLink(int i, int j, float weight){
	std::pair<int, int> p(i, j);
	if (j < i) {
		p = std::make_pair(j, i);
	}
	mPossibleLinkMap[p] = weight;
}

void SemiSupervisedKernel::connectedComponent(
		std::vector<std::vector<int> >* pComponentArray) {
	std::vector<int> component(num_vertices(mMustLinkGraph));
	int num = connected_components(mMustLinkGraph, &component[0]);
	pComponentArray->resize(num);
	std::vector<int> _dummy;
	pComponentArray->assign(num, _dummy);
	std::vector<std::vector<int> > _components(num, _dummy);
	VertexIter vi, vi_end;
	for (tie(vi, vi_end) = vertices(mMustLinkGraph); vi != vi_end; vi++) {
		int ccIndex = component[*vi];
		_components[ccIndex].push_back((int) (*vi));
	}
	std::vector<RankItem<int, int> > rankList;
	for (size_t i = 0; i < _components.size(); ++i) {
		RankItem<int, int> item((int) i, -1 * (int) _components[i].size());
		rankList.push_back(item);
	}
	std::sort(rankList.begin(), rankList.end());
	for (size_t i = 0; i < _components.size(); ++i) {
		int index = rankList[i].index;
		pComponentArray->at(i) = _components[index];
	}
}

void SemiSupervisedKernel::processMustLink() {
	std::vector<std::vector<int> > componentArray;
	connectedComponent(&componentArray);
	for (size_t i = 0; i < componentArray.size(); ++i) {
		std::vector<int>& component = componentArray[i];
		std::sort(component.begin(), component.end());
		for (size_t j = 0; j < component.size(); ++j) {
			for (size_t k = j + 1; k < component.size(); ++k) {
				mMustLinkSet.insert(
						std::pair<int, int>(component[j], component[k]));
			}
		}
	}
}
