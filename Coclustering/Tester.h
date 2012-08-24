#pragma once
#include <opencv2/opencv.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bimap.hpp>
#include <algorithm>
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
// this class is used for testing functions
class Tester {
public:
	Tester(void);
	~Tester(void);
	//static void testKKClusterer();
	//static void testFaceFeature();
	//static void testSIFTFeature();
	//static void testTrain();
	//static void testFaceAccuracy();
	//static void testFlandmark();
	//static void testPCA();
	//static void testDownloadPubFig();
	//static void testVocabulary();
	//static void testLocationFeature();
	//static void testGroundTruth();
	//static void testFaceClustering();
	//static void testLocationClustering();
	//static void testFlickr();
	//static void testFlickrFace();
	//static void testCosegmentation();
	// each line in the file specifies one people name appears at this location.
	static void buildLocationBasedClassifier(const std::string& filepath);
	static void testBaseline();
	static void testAccuracy(const std::string& locationName);
	static void testIllumination();
	static void testLFWA();
	static void testHalf();
	static void testVelocity();
	static void testCalibration();
	static void testTracker();
	static void testProjection();
};

