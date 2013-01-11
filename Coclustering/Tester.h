#pragma once
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bimap.hpp>
#include <algorithm>
#include <boost/graph/graph_traits.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/dijkstra_shortest_paths.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/array.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "KernelKmeansClusterer.h"
#include "CascadeDetector.h"
#include "FaceDescriptor.h"
#include "FaceLandmarkDetector.h"
#include "KnnClassifier.h"
#include "SVMClassifier.h"
#include "PCACompressor.h"
#include "Vocabulary.h"
#include "BoWDescriptor.h"
#include "ColorDescriptor.h"
#include "ImageResizer.h"
#include "RandIndexComputer.h"
#include "RobustMatcher.h"
#include "File.h"
#include "IlluminationNormalizer.h"
#include "Evaluation.h"
#include "RankItem.h"
#include "VelocityComputer.h"
#include "CameraCalibrator.h"
#include "Tracker.h"
#include "PlanarObjectTracker.h"
#include "Ticker.h"
#include "Evaluation.h"
#include "SemiSupervisedKernel.h"
#include "HeartRateComputer.h"
// this class is used for testing functions
class Tester {
public:
	Tester(void);
	~Tester(void);
//	static void buildLocationBasedClassifier(const std::string& filepath);
//	static void testBaseline();
//	static void testAccuracy(const std::string& locationName);
//	static void testIllumination();
//	static void testLFWA();
//	static void testHalf();
//	static void testVelocity();
//	static void testCalibration();
//	static void testSolvePnP();
//	static void testCapture();
//	static void testFace();
//	static void testLocation();
//	static void testFaceFeature();
//	static void testLocationCluster();
//	static void testLocationFeature();
//	static void testVocabulary();
//	static void testMustLink();
//	static void testLocationBaseLine();
//	static void testFaceBaseLine();
//	static void testCoclustering();
	static void testVideo();
};

