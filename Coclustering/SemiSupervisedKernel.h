#pragma once
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/connected_components.hpp>
#include <boost/unordered_set.hpp>
#include "Kernel.h"
#include "LinearKernel.h"
#include "RankItem.h"
class SemiSupervisedKernel
{
typedef boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS> GraphBase;
typedef boost::graph_traits<GraphBase>::vertex_descriptor VertexDesc;
typedef boost::graph_traits<GraphBase>::edge_descriptor EdgeDesc;
typedef boost::graph_traits<GraphBase>::vertex_iterator VertexIter;
typedef boost::graph_traits<GraphBase>::edge_iterator EdgeIter;
typedef boost::graph_traits<GraphBase>::out_edge_iterator OutEdgeIter;
public:
	SemiSupervisedKernel(std::vector<Sample>* pSampleArray);
	virtual ~SemiSupervisedKernel(void);
	virtual float operator()(int i, int j) const;
	void addMustLink(int i, int j);
	void addCannotLink(int i, int j);
	void connectedComponent(std::vector<std::vector<int> >* pComponentArray);
	// after adding all must links, run this function to build the data structure.
	void processMustLink();
private:
	GraphBase mMustLinkGraph;
	boost::unordered_set<std::pair<int, int> > mMustLinkSet;
	boost::unordered_set<std::pair<int, int> > mCannotLinkSet;
	const static float mustLinkWeight;
	const static float cannotLinkWeight;
	LinearKernel mKernel;
};

