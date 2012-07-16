#include "Tester.h"
int main(int argc, char* argv[]){
	//Tester::testKKClusterer();
	//Tester::testFaceFeature();
	//Tester::testSIFTFeature();
	//Tester::testTrain();
	//Tester::testFaceAccuracy();
	//Tester::testType();
	//Tester::testFlandmark();
	//Tester::testPCA();
	//Tester::testDownloadPubFig();
	//Tester::testVocabulary();
	//Tester::testLocationFeature();
	//Tester::testGroundTruth();
	//Tester::testFaceClustering();
	//Tester::testLocationClustering();
	//Tester::testFlickr();
	//Tester::testCosegmentation();
	//Tester::testFlickrFace();
	//Tester::testBaseline();
	//Tester::testMat();
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l0.txt");
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l1.txt");
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l2.txt");
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l3.txt");
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l4.txt");
	//Tester::buildLocationBasedClassifier("C:/dataset/location/l5.txt");
	for(int i=0;i<7;++i){
		std::string locationName="l"+boost::lexical_cast<std::string>(i);
		for(int j=0;j<5;++j){
			Tester::testAccuracy(locationName);
		}
	}
	getchar();
	return 0;
}