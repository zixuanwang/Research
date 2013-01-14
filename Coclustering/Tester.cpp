#include "Tester.h"

Tester::Tester(void) {
}

Tester::~Tester(void) {
}

//void Tester::testKKClusterer(){
//	int width=400;
//	int height=400;
//	int sampleCount=1000;
//	int clusterCount=10;
//	KernelKmeansClusterer kkc(clusterCount,10);
//	// generate random samples
//	srand((unsigned int)time(NULL));
//	for(int i=0;i<sampleCount;++i){
//		float x=(float)(rand()%width);
//		float y=(float)(rand()%height);
//		Sample sample(2);
//		sample[0]=x;
//		sample[1]=y;
//		// add the sample
//		kkc.addSample(sample);
//	}
//	kkc.initialize();
//	kkc.cluster();
//	// draw samples
//	// generate color pallete
//	std::vector<cv::Scalar> pallete;
//	for(int i=0;i<clusterCount;++i){
//		pallete.push_back(cv::Scalar(rand()%255,rand()%255,rand()%255,0));
//	}
//	// get the clustering result
//	std::vector<int> labelArray=kkc.labelArray();
//	cv::namedWindow("testWindow");
//	cv::Mat image(height,width,CV_8UC3,cv::Scalar(255,255,255,0));
//	for(int i=0;i<kkc.sampleCount();++i){
//		Sample sample=kkc.sample(i);
//		cv::circle(image,cv::Point2f(sample[0],sample[1]),1,pallete[labelArray[i]],1,CV_AA,0);
//	}
//	cv::imshow("testWindow",image);
//	cv::waitKey(0);
//}

//void Tester::testSIFTFeature(){
//	std::string imagePath="C:/test.jpg";
//	cv::Mat image=cv::imread(imagePath,0);
//	cv::SIFT sift;
//	std::vector<cv::KeyPoint> keypointArray;
//	cv::Mat descriptor;
//	sift(image, cv::Mat(), keypointArray, descriptor);
//	for(size_t i=0;i<keypointArray.size();++i){
//		cv::KeyPoint& keypoint=keypointArray[i];
//		std::cout<<"x: "<<keypoint.pt.x<<" y: "<<keypoint.pt.y<<" size: "<<keypoint.size<<" angle: "<<keypoint.angle<<" response: "<<keypoint.response<<" octave: "<<keypoint.octave<<" class_id: "<<keypoint.class_id<<std::endl;
//	}
//}
//
//void Tester::testTrain(){
//	std::string imageDirectory = "C:/dataset/small_lfw";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	KnnClassifier knnClassifier;
//	boost::unordered_map<std::string, int> nameLabelMap;
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	for(size_t i=0;i<filenameArray.size();++i){
//		// get people name
//		std::string peopleName=File::getParentDirectory(filenameArray[i]);
//		if(nameLabelMap.find(peopleName)==nameLabelMap.end()){
//			nameLabelMap[peopleName]=(int)nameLabelMap.size();
//		}
//		cv::Mat image = cv::imread(filenameArray[i], 0);
//		std::vector<cv::Rect> faceArray;
//		FaceDetector::instance()->detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Point2f> landmarkArray;
//			FaceLandmarkDetector::instance()->detect(&landmarkArray,image,faceArray[0]);
//			std::vector<cv::Point2f> normalizedLandmarkArray;
//			cv::Mat normalizedFace=FaceLandmarkDetector::instance()->normalize(&normalizedLandmarkArray,image,faceArray[0],landmarkArray);
//			std::vector<cv::Point2f> warpedLandmarkArray;
//			cv::Mat warpedFace=FaceLandmarkDetector::instance()->warp(&warpedLandmarkArray,normalizedFace,normalizedLandmarkArray);
//			// remove the face center
//			std::vector<cv::Point2f> finalLandmarkArray(warpedLandmarkArray.begin()+1,warpedLandmarkArray.end());
//			// compute the face descriptor
//			Sample faceSample=FaceDescriptor::instance()->compute(warpedFace,finalLandmarkArray);
//			knnClassifier.addSample(faceSample,nameLabelMap[peopleName]);
//			std::cout << "Processing image " << filenameArray[i] << std::endl;
//		}
//	}
//	knnClassifier.build();
//	knnClassifier.save("C:/lfw");
//	std::ofstream outStream;
//	outStream.open("C:/lfw.name");
//	if (outStream.good()) {
//		for(boost::unordered_map<std::string, int>::iterator iter=nameLabelMap.begin();iter!=nameLabelMap.end();++iter){
//			outStream<<iter->first<<"\t"<<iter->second<<std::endl;
//		}
//		outStream.close();
//	}
//}
//
//void Tester::testFaceAccuracy(){
//	srand((unsigned int)time(NULL));
//	std::string imageDirectory = "C:/dataset/small_lfw";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	boost::unordered_map<std::string, int> nameLabelMap;
//	KnnClassifier knnClassifier;
//	knnClassifier.load("C:/lfw");
//	std::ifstream inStream;
//	inStream.open("C:/lfw.name");
//	if (inStream.good()) {
//		std::string line;
//		while(getline(inStream,line)){
//			std::vector<std::string> tokenArray;
//			boost::split(tokenArray, line, boost::is_any_of("\t"));
//			nameLabelMap[tokenArray[0]]=boost::lexical_cast<int>(tokenArray[1]);
//		}
//		inStream.close();
//	}
//	int iterations=100;
//	int testCount=0;
//	int correctCount=0;
//	for(int i=0;i<iterations;++i){
//		int index=rand()%filenameArray.size();
//		std::string peopleName=File::getParentDirectory(filenameArray[index]);
//		int label=nameLabelMap[peopleName];
//		cv::Mat image=cv::imread(filenameArray[index],0);
//		std::vector<cv::Rect> faceArray;
//		FaceDetector::instance()->detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Point2f> landmarkArray;
//			FaceLandmarkDetector::instance()->detect(&landmarkArray,image,faceArray[0]);
//			std::vector<cv::Point2f> normalizedLandmarkArray;
//			cv::Mat normalizedFace=FaceLandmarkDetector::instance()->normalize(&normalizedLandmarkArray,image,faceArray[0],landmarkArray);
//			std::vector<cv::Point2f> warpedLandmarkArray;
//			cv::Mat warpedFace=FaceLandmarkDetector::instance()->warp(&warpedLandmarkArray,normalizedFace,normalizedLandmarkArray);
//			// remove the face center
//			std::vector<cv::Point2f> finalLandmarkArray(warpedLandmarkArray.begin()+1,warpedLandmarkArray.end());
//			// compute the face descriptor
//			Sample faceSample=FaceDescriptor::instance()->compute(warpedFace,finalLandmarkArray);
//			std::vector<int> resultArray=knnClassifier.query(faceSample,2);
//			if(resultArray[1]==label){
//				correctCount++;
//			}
//			testCount++;
//		}
//	}
//	std::cout<<"accuracy: "<<correctCount<<"/"<<testCount<<"="<<(float)correctCount/testCount<<std::endl;
//}
//
//void Tester::testFlandmark(){
//	std::string imageDirectory = "C:/dataset/lfw";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	int faceCount=0;
//	std::vector<cv::Point2f> averageArray(8);
//	for (size_t i = 0; i < filenameArray.size(); ++i) {
//		cv::Mat image = cv::imread(filenameArray[i], 0);
//		std::vector<cv::Rect> faceArray;
//		FaceDetector::instance()->detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Point2f> landmarkArray;
//			FaceLandmarkDetector::instance()->detect(&landmarkArray,image,faceArray[0]);
//			std::vector<cv::Point2f> normalizedLandmarkArray;
//			cv::Mat normalizedFace=FaceLandmarkDetector::instance()->normalize(&normalizedLandmarkArray,image,faceArray[0],landmarkArray);
//			for(size_t j=0;j<normalizedLandmarkArray.size();++j){
//				averageArray[j].x+=normalizedLandmarkArray[j].x;
//				averageArray[j].y+=normalizedLandmarkArray[j].y;
//			}
//			++faceCount;
//		}
//		std::cout << "Processing image " << filenameArray[i] << std::endl;
//	}
//	for(size_t i=0;i<averageArray.size();++i){
//		std::cout<<i<<"\t<"<<averageArray[i].x/faceCount<<", "<<averageArray[i].y/faceCount<<">"<<std::endl;
//	}
//}
//
//void Tester::testPCA(){
//	std::string imageDirectory = "C:/dataset/small_lfw";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	KnnClassifier knnClassifier;
//	boost::unordered_map<std::string, int> nameLabelMap;
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	std::vector<PCACompressor> pcaArray(7);
//	for(size_t i=0;i<filenameArray.size();++i){
//		// get people name
//		std::string peopleName=File::getParentDirectory(filenameArray[i]);
//		if(nameLabelMap.find(peopleName)==nameLabelMap.end()){
//			nameLabelMap[peopleName]=(int)nameLabelMap.size();
//		}
//		cv::Mat image = cv::imread(filenameArray[i], 0);
//		std::vector<cv::Rect> faceArray;
//		FaceDetector::instance()->detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Point2f> landmarkArray;
//			FaceLandmarkDetector::instance()->detect(&landmarkArray,image,faceArray[0]);
//			std::vector<cv::Point2f> normalizedLandmarkArray;
//			cv::Mat normalizedFace=FaceLandmarkDetector::instance()->normalize(&normalizedLandmarkArray,image,faceArray[0],landmarkArray);
//			std::vector<cv::Point2f> warpedLandmarkArray;
//			cv::Mat warpedFace=FaceLandmarkDetector::instance()->warp(&warpedLandmarkArray,normalizedFace,normalizedLandmarkArray);
//			for(size_t i=1;i<warpedLandmarkArray.size();++i){
//				Sample sample=FaceDescriptor::instance()->compute(warpedFace,warpedLandmarkArray[i]);
//				pcaArray[i-1].addSample(sample);
//			}
//		}
//	}
//	for(size_t i=0;i<filenameArray.size();++i){
//		cv::Mat compressed;
//		pcaArray[i].compress(&compressed,80);
//	}
//}
//
//void Tester::testDownloadPubFig(){
//	std::string urlPath="C:/Users/t-ziwan/Desktop/dev_urls.txt";
//	std::string outputDirectory="C:/dataset/pubfig";
//	boost::filesystem::path bstOutputDirectory=outputDirectory;
//    std::ifstream inStream;
//    inStream.open(urlPath.c_str());
//    if(inStream.good()){
//        std::string line;
//        while(getline(inStream,line)){
//			std::vector<std::string> tokenArray;
//			boost::split(tokenArray, line, boost::is_any_of("\t"));
//			tokenArray[0].erase(std::remove_if(tokenArray[0].begin(), tokenArray[0].end(), isspace), tokenArray[0].end());			
//			boost::filesystem::path directory=bstOutputDirectory/tokenArray[0];
//			boost::filesystem::create_directories(directory);
//			std::string cmd="C:/Users/t-ziwan/local/bin/wget ";
//			cmd+=tokenArray[2]+" -O " + (directory/tokenArray[4]).string()+".jpg";
//			system(cmd.c_str());
//			std::cout<<cmd<<std::endl;
//        }
//        inStream.close();
//    }
//}
//
//void Tester::testVocabulary(){
//	std::string imageDirectory="C:/Users/t-ziwan/Dropbox/data";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	std::vector<float> sampleArray;
//	int sampleCount=0;
//	for(size_t i=0;i<filenameArray.size();++i){
//		boost::filesystem::path bstFilePath=filenameArray[i];
//		if(bstFilePath.extension().string()==".jpg"){
//			cv::Mat image=cv::imread(filenameArray[i],0);
//			cv::Mat resizedImage;
//			ImageResizer::resize(image,&resizedImage,1024);
//			std::vector<cv::KeyPoint> keypoint;
//			cv::Mat descriptor;
//			BoWDescriptor::instance()->extractDescriptor(&keypoint,&descriptor,resizedImage);
//			std::copy(descriptor.ptr<float>(0),descriptor.ptr<float>(0)+descriptor.rows*descriptor.cols,std::back_inserter(sampleArray));
//			sampleCount+=descriptor.rows;
//		}
//	}
//	cv::Mat sampleMat(sampleArray,false);
//	sampleMat=sampleMat.reshape(0,sampleCount);
//	Vocabulary::instance()->build(sampleMat,1000);
//	Vocabulary::instance()->save("C:/voc_1k.dat");
//}
//
//void Tester::testLocationFeature(){
//	std::string imageDirectory="C:/Users/t-ziwan/Dropbox/data";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	Vocabulary::instance()->load("C:/voc_1k.dat");
//	for(size_t i=0;i<filenameArray.size();++i){
//		boost::filesystem::path bstFilePath=filenameArray[i];
//		if(bstFilePath.extension().string()==".jpg"){
//			// compute bow feature
//			cv::Mat image=cv::imread(filenameArray[i],0);
//			cv::Mat resizedImage;
//			ImageResizer::resize(image,&resizedImage,1024);
//			Sample bowSample=BoWDescriptor::instance()->compute(resizedImage);
//			// compute color feature
//			image=cv::imread(filenameArray[i],1);
//			ImageResizer::resize(image,&resizedImage,1024);
//			Sample colorSample=ColorDescriptor::instance()->compute(resizedImage);
//			//bowSample.print();
//			colorSample.print();
//		}
//	}
//}
//
//void Tester::testGroundTruth(){
//	std::string imageDirectory="C:/Users/t-ziwan/Dropbox/data";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	Vocabulary::instance()->load("C:/voc_1k.dat");
//	std::ofstream outStream("C:/Users/t-ziwan/Dropbox/data/location.txt");
//	boost::filesystem::path bstFacePatchDir="C:/Users/t-ziwan/Desktop/face";
//	boost::filesystem::create_directories(bstFacePatchDir);
//	cv::namedWindow("test");
//	for(size_t i=0;i<filenameArray.size();++i){
//		boost::filesystem::path bstFilePath=filenameArray[i];
//		if(bstFilePath.extension().string()==".jpg"){
//			cv::Mat image = cv::imread(filenameArray[i], 0);
//			cv::Mat resizedImage;
//			ImageResizer::resize(image,&resizedImage,1024);
//			image=resizedImage;
//			boost::filesystem::path bstFilepath=filenameArray[i];
//			std::string filestem=bstFilepath.stem().string();
//			Sample bowSample=BoWDescriptor::instance()->compute(image);
//			std::string bowSampleString;
//			bowSample.save(&bowSampleString);
//			image=cv::imread(filenameArray[i]);
//			ImageResizer::resize(image,&resizedImage,1024);
//			image=resizedImage;
//			Sample colorSample=ColorDescriptor::instance()->compute(image);
//			std::string colorSampleString;
//			colorSample.save(&colorSampleString);
//			cv::imshow("test",image);
//			cv::waitKey(0);
//			std::string label;
//			std::cin>>label;
//			outStream<<filestem<<"\t"<<bowSampleString<<"\t"<<colorSampleString<<"\t"<<label<<std::endl;
//		}
//	}
//	outStream.close();
//}
//
//void Tester::testFaceClustering(){
//	for(int clusterCount=1;clusterCount<=100;++clusterCount){
//		std::string faceGroudtruthPath="C:/Users/t-ziwan/Dropbox/data/face.txt";
//		std::ifstream inStream;
//		inStream.open(faceGroudtruthPath.c_str());
//		RandIndexComputer computer;
//		computer.loadGroundTruth(faceGroudtruthPath);
//		boost::unordered_map<std::string, std::string> patchLabelMap;
//		boost::bimap<std::string, int> patchIdMap;
//		int i=0;
//		KernelKmeansClusterer kkc(clusterCount,30);
//		if(inStream.good()){
//			std::string line;
//			while(getline(inStream,line)){
//				std::vector<std::string> tokenArray;
//				boost::split(tokenArray, line, boost::is_any_of("\t"));
//				if(!tokenArray.empty()){
//					patchIdMap.insert(boost::bimap<std::string, int>::value_type(tokenArray[0], i));
//					Sample sample;
//					sample.load(tokenArray[1]);
//					kkc.addSample(sample);
//					++i;
//				}
//			}
//			inStream.close();
//		}
//		kkc.initialize();
//		kkc.cluster();
//		std::vector<int> labelArray=kkc.labelArray();
//		for(size_t i=0;i<labelArray.size();++i){
//			patchLabelMap[patchIdMap.right.at(i)]=boost::lexical_cast<std::string>(labelArray[i]);
//		}
//		std::cout<<computer.compute(patchLabelMap)<<std::endl;
//	}
//}
//
//void Tester::testLocationClustering(){
//	for(int clusterCount=1;clusterCount<=100;++clusterCount){
//		std::string locationGroudtruthPath="C:/Users/t-ziwan/Dropbox/data/location.txt";
//		std::ifstream inStream;
//		inStream.open(locationGroudtruthPath.c_str());
//		RandIndexComputer computer;
//		computer.loadGroundTruth(locationGroudtruthPath);
//		boost::unordered_map<std::string, std::string> patchLabelMap;
//		boost::bimap<std::string, int> patchIdMap;
//		int i=0;
//		KernelKmeansClusterer kkc(clusterCount,30);
//		if(inStream.good()){
//			std::string line;
//			while(getline(inStream,line)){
//				std::vector<std::string> tokenArray;
//				boost::split(tokenArray, line, boost::is_any_of("\t"));
//				if(!tokenArray.empty()){
//					patchIdMap.insert(boost::bimap<std::string, int>::value_type(tokenArray[0], i));
//					Sample sample;
//					sample.load(tokenArray[1]+","+tokenArray[2]);
//					sample.normalize();
//					kkc.addSample(sample);
//					++i;
//				}
//			}
//			inStream.close();
//		}
//		kkc.initialize();
//		kkc.cluster();
//		std::vector<int> labelArray=kkc.labelArray();
//		for(size_t i=0;i<labelArray.size();++i){
//			patchLabelMap[patchIdMap.right.at(i)]=boost::lexical_cast<std::string>(labelArray[i]);
//		}
//		std::cout<<computer.compute(patchLabelMap)<<std::endl;
//	}
//}
//
//void Tester::testFlickr(){
//	std::string imageDirectory="C:/Users/t-ziwan/Desktop/flickr/photos";
//	//std::string imageDirectory="C:/Users/t-ziwan/Dropbox/data";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath =
//			"C:/flandmark_model.dat";
//	Vocabulary::instance()->load("C:/voc_1k.dat");
//	FaceDetector::instance()->initNested(cascadeName, nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::ofstream locationOutStream("C:/Users/t-ziwan/Desktop/location.txt");
//	std::ofstream faceOutStream("C:/Users/t-ziwan/Desktop/face.txt");
//	boost::filesystem::path bstFacePatchDir="C:/Users/t-ziwan/Desktop/face";
//	boost::filesystem::path bstLocationPatchDir="C:/Users/t-ziwan/Desktop/location";
//	boost::filesystem::create_directories(bstFacePatchDir);
//	boost::filesystem::create_directories(bstLocationPatchDir);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	// output face patch and location patch
//	for(size_t i=0;i<filenameArray.size();++i){
//		// compute face patch
//		boost::filesystem::path bstFilepath=filenameArray[i];
//		std::string filestem=bstFilepath.stem().string();
//		if(bstFilepath.extension().string()!=".jpg"){
//			continue;
//		}
//		cv::Mat image=cv::imread(filenameArray[i],0);
//		cv::Mat colorImage=cv::imread(filenameArray[i]);
//		std::vector<cv::Rect> faceArray;
//		FaceDetector::instance()->detect(&faceArray, image);
//		for(size_t j=0;j<faceArray.size();++j){
//			std::vector<cv::Point2f> landmarkArray;
//			FaceLandmarkDetector::instance()->detect(&landmarkArray,image,faceArray[j]);
//			std::vector<cv::Point2f> normalizedLandmarkArray;
//			cv::Mat normalizedFace=FaceLandmarkDetector::instance()->normalize(&normalizedLandmarkArray,image,faceArray[j],landmarkArray);
//			std::vector<cv::Point2f> warpedLandmarkArray;
//			cv::Mat warpedFace=FaceLandmarkDetector::instance()->warp(&warpedLandmarkArray,normalizedFace,normalizedLandmarkArray);
//			// remove the face center
//			std::vector<cv::Point2f> finalLandmarkArray(warpedLandmarkArray.begin()+1,warpedLandmarkArray.end());
//			// compute the face descriptor
//			Sample faceSample=FaceDescriptor::instance()->compute(warpedFace,finalLandmarkArray);
//			std::string faceSampleString;
//			faceSample.save(&faceSampleString);
//			// save face patch
//			std::string patchName=filestem+boost::lexical_cast<std::string>(j)+".jpg";
//			cv::imwrite((bstFacePatchDir/patchName).string(),normalizedFace);
//			faceOutStream<<patchName<<"\t"<<faceSampleString<<std::endl;
//		}
//		if(!faceArray.empty()){
//			// location feature
//			Sample bowSample=BoWDescriptor::instance()->compute(image);
//			std::string bowSampleString;
//			bowSample.save(&bowSampleString);
//			Sample colorSample=ColorDescriptor::instance()->compute(colorImage);
//			std::string colorSampleString;
//			colorSample.save(&colorSampleString);
//			locationOutStream<<filenameArray[i]<<"\t"<<bowSampleString<<"\t"<<colorSampleString<<std::endl;
//		}
//		std::cout<<i<<std::endl;
//	}
//	locationOutStream.close();
//	faceOutStream.close();
//}
//
//void Tester::testCosegmentation(){
//	std::string locationPath="C:/Users/t-ziwan/Desktop/location.txt";
//	std::ifstream inStream;
//	inStream.open(locationPath.c_str());
//	std::vector<std::string> filePathArray;
//	std::vector<Sample> sampleArray;
//	KnnClassifier knn;
//	if(inStream.good()){
//		std::string line;
//		while(getline(inStream,line)){
//			std::vector<std::string> tokenArray;
//			boost::split(tokenArray, line, boost::is_any_of("\t"));
//			if(!tokenArray.empty()){
//				std::string sampleString=tokenArray[1]+","+tokenArray[2];
//				Sample sample;
//				sample.load(sampleString);
//				sample.normalize();
//				knn.addSample(sample,(int)filePathArray.size());
//				sampleArray.push_back(sample);
//				filePathArray.push_back(tokenArray[0]);
//			}
//			
//		}
//		inStream.close();
//	}
//	knn.build();
//	boost::filesystem::path outDir="C:/Users/t-ziwan/Desktop/location";
//	for(size_t i=0;i<filePathArray.size();++i){
//		std::string imagePath1=filePathArray[i];
//		boost::filesystem::path bstImagePath1=imagePath1;
//		std::string filestem1=bstImagePath1.stem().string();
//		cv::Mat image1=cv::imread(imagePath1,0);
//		std::vector<int> candidateIdArray=knn.query(sampleArray[i],30);
//		for(size_t j=0;j<candidateIdArray.size();++j){
//			std::string imagePath2=filePathArray[candidateIdArray[j]];
//			if(imagePath2==imagePath1){
//				continue;
//			}
//			cv::Mat image2=cv::imread(imagePath2,0);
//			RobustMatcher matcher;
//			std::vector<cv::KeyPoint> keypoint1;
//			std::vector<cv::KeyPoint> keypoint2;
//			cv::Mat H=matcher.match(image1,image2,&keypoint1,&keypoint2);
//			if(H.empty()){
//				continue;
//			}
//			boost::filesystem::path bstImagePath2=imagePath2;
//			std::string filestem2=bstImagePath2.stem().string();
//			cv::Mat patch1=matcher.patch(image1,keypoint1);
//			cv::Mat patch2=matcher.patch(image2,keypoint2);
//			cv::imwrite((outDir/(filestem1+"!"+filestem2+".jpg")).string(),patch1);
//			cv::imwrite((outDir/(filestem2+"!"+filestem1+".jpg")).string(),patch2);
//			std::cout<<"cosegmenting "<<imagePath1<<" and "<<imagePath2<<std::endl;
//		}
//	}
//}
//
//void Tester::testFlickrFace(){
//	for(int clusterCount=100;clusterCount<=500;clusterCount+=100){
//		std::string facePath="C:/Users/t-ziwan/Desktop/face.txt";
//		boost::filesystem::path bstOutputDir="C:/Users/t-ziwan/Desktop/face_cluster";
//		boost::filesystem::path bstInputDir="C:/Users/t-ziwan/Desktop/face";
//		std::ifstream inStream;
//		inStream.open(facePath.c_str());
//		std::vector<std::string> faceNameArray;
//		KernelKmeansClusterer kkc(clusterCount,10);
//		if(inStream.good()){
//			std::string line;
//			while(getline(inStream,line)){
//				std::vector<std::string> tokenArray;
//				boost::split(tokenArray, line, boost::is_any_of("\t"));
//				if(!tokenArray.empty()){
//					std::string sampleString=tokenArray[1];
//					Sample sample;
//					sample.load(sampleString);
//					kkc.addSample(sample);
//					faceNameArray.push_back(tokenArray[0]);
//				}
//			}
//			inStream.close();
//		}
//		kkc.initialize();
//		kkc.cluster();
//		std::vector<int> labelArray=kkc.labelArray();
//		bstOutputDir/=boost::lexical_cast<std::string>(clusterCount);
//		boost::filesystem::create_directories(bstOutputDir);
//		for(size_t i=0;i<labelArray.size();++i){
//			boost::filesystem::path path=bstOutputDir/boost::lexical_cast<std::string>(labelArray[i]);
//			boost::filesystem::create_directories(path);
//			std::string inputPath=(bstInputDir/faceNameArray[i]).string();
//			std::string outputPath=(path/faceNameArray[i]).string();
//			cv::Mat image=cv::imread(inputPath);
//			cv::imwrite(outputPath,image);
//		}
//		std::cout<<clusterCount<<std::endl;
//	}
//}

//void Tester::buildLocationBasedClassifier(const std::string& filepath) {
//	std::string imageDirectory = "C:/dataset/pubfig";
//	std::string outputDirectory = "C:/Users/t-ziwan/Desktop/location";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath = "C:/flandmark_model.dat";
//	SVMClassifier svmClassifier;
//	// initialize detectors
//	CascadeDetector faceDetector;
//	CascadeDetector noseDetector;
//	faceDetector.init(cascadeName);
//	noseDetector.init(nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> nameArray;
//	std::vector<std::string> trainArray;
//	Serializer::loadStringArray(nameArray, filepath);
//	boost::unordered_map<std::string, int> nameLabelMap;
//	for (size_t i = 0; i < nameArray.size(); ++i) {
//		nameLabelMap[nameArray[i]] = (int) i;
//		std::vector<std::string> filenameArray;
//		File::getFiles(&filenameArray, imageDirectory + "/" + nameArray[i],
//				true);
//		for (size_t j = 0; j < filenameArray.size(); ++j) {
//			cv::Mat image = cv::imread(filenameArray[j], 0);
//			std::vector<cv::Rect> faceArray;
//			faceDetector.detect(&faceArray, image);
//			if (faceArray.size() == 1) {
//				std::vector<cv::Rect> noseArray;
//				noseDetector.detect(&noseArray, image(faceArray[0]));
//				if (noseArray.size() == 1) {
//					std::vector<cv::Point2f> landmarkArray;
//					cv::Mat faceMat =
//							FaceLandmarkDetector::instance()->getLandmark(
//									&landmarkArray, image, faceArray[0]);
//					Sample faceSample = FaceDescriptor::instance()->compute(
//							faceMat, landmarkArray);
//					svmClassifier.addSample(faceSample, (int) i);
//					trainArray.push_back(filenameArray[j]);
//				}
//			}
//		}
//		std::cout << "Processing " << nameArray[i] << std::endl;
//	}
//	std::string filestem = File::getFileStem(filepath);
//	svmClassifier.build();
//	svmClassifier.save(outputDirectory + "/" + filestem);
//	Serializer::saveStringMap(nameLabelMap,
//			outputDirectory + "/" + filestem + ".name");
//	Serializer::saveStringArray(trainArray,
//			outputDirectory + "/" + filestem + ".train");
//}
//
//void Tester::testBaseline() {
//	std::string imageDirectory = "C:/dataset/pubfig";
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath = "C:/flandmark_model.dat";
//	KnnClassifier knnClassifier;
//	// initialize detectors
//	CascadeDetector faceDetector;
//	CascadeDetector noseDetector;
//	faceDetector.init(cascadeName);
//	noseDetector.init(nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	boost::unordered_map<std::string, int> nameLabelMap;
//	std::vector<std::string> trainArray;
//	for (size_t i = 0; i < filenameArray.size(); ++i) {
//		cv::Mat image = cv::imread(filenameArray[i], 0);
//		std::vector<cv::Rect> faceArray;
//		faceDetector.detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Rect> noseArray;
//			noseDetector.detect(&noseArray, image(faceArray[0]));
//			if (noseArray.size() == 1) {
//				std::string name = File::getParentDirectory(filenameArray[i]);
//				if (nameLabelMap.find(name) == nameLabelMap.end()) {
//					nameLabelMap[name] = (int) nameLabelMap.size();
//				}
//				std::vector<cv::Point2f> landmarkArray;
//				cv::Mat faceMat = FaceLandmarkDetector::instance()->getLandmark(
//						&landmarkArray, image, faceArray[0]);
//				Sample faceSample = FaceDescriptor::instance()->compute(faceMat,
//						landmarkArray);
//				knnClassifier.addSample(faceSample, nameLabelMap[name]);
//				trainArray.push_back(filenameArray[i]);
//			}
//		}
//		std::cout << "Processing " << filenameArray[i] << "\t" << i
//				<< " out of " << filenameArray.size() << std::endl;
//	}
//	knnClassifier.build();
//	knnClassifier.save("C:/Users/t-ziwan/Desktop/pubfig");
//	Serializer::saveStringMap(nameLabelMap,
//			"C:/Users/t-ziwan/Desktop/pubfig.name");
//	Serializer::saveStringArray(trainArray,
//			"C:/Users/t-ziwan/Desktop/pubfig.train");
//}
//
//void Tester::testAccuracy(const std::string& locationName) {
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	std::string modelPath = "C:/flandmark_model.dat";
//	std::vector<std::string> trainArray;
//	Serializer::loadStringArray(trainArray,
//			"C:/Users/t-ziwan/Desktop/location/" + locationName + ".train");
//	// load classifier
//	KnnClassifier classifier;
//	classifier.load("C:/Users/t-ziwan/Desktop/location/" + locationName);
//	classifier.build();
//	boost::unordered_map<std::string, int> nameLabelMap;
//	Serializer::loadStringMap(nameLabelMap,
//			"C:/Users/t-ziwan/Desktop/location/" + locationName + ".name");
//	// initialize detectors
//	CascadeDetector faceDetector;
//	CascadeDetector noseDetector;
//	faceDetector.init(cascadeName);
//	noseDetector.init(nestedCascadeName);
//	FaceLandmarkDetector::instance()->init(modelPath);
//	// construct the test set
//	size_t testSize = 100;
//	srand((unsigned int) time(NULL));
//	boost::unordered_set<std::string> testSet;
//	while (testSet.size() < testSize) {
//		testSet.insert(trainArray[rand() % trainArray.size()]);
//	}
//	float correct = 0;
//	for (boost::unordered_set<std::string>::iterator iter = testSet.begin();
//			iter != testSet.end(); ++iter) {
//		std::string testPath = *iter;
//		cv::Mat image = cv::imread(testPath, 0);
//		std::vector<cv::Rect> faceArray;
//		faceDetector.detect(&faceArray, image);
//		if (faceArray.size() == 1) {
//			std::vector<cv::Rect> noseArray;
//			noseDetector.detect(&noseArray, image(faceArray[0]));
//			if (noseArray.size() == 1) {
//				std::string name = File::getParentDirectory(testPath);
//				std::vector<cv::Point2f> landmarkArray;
//				cv::Mat faceMat = FaceLandmarkDetector::instance()->getLandmark(
//						&landmarkArray, image, faceArray[0]);
//				Sample faceSample = FaceDescriptor::instance()->compute(faceMat,
//						landmarkArray);
//				int queryResult = classifier.query(faceSample);
//				if (nameLabelMap[name] == queryResult) {
//					++correct;
//				}
//			}
//		}
//	}
//	std::cout << locationName << " Accuracy: " << correct / testSize
//			<< std::endl;
//}
//
//void Tester::testIllumination() {
//	std::string imageDirectory = "/home/zixuanwang/dataset/pubfig";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	cv::namedWindow("test");
//	for (size_t i = 0; i < filenameArray.size(); ++i) {
//		cv::Mat image = cv::imread(filenameArray[i], 0);
//		cv::Mat normalizedImage;
//		IlluminationNormalizer::normalize(&normalizedImage, image);
//		cv::imshow("test", normalizedImage);
//		cv::waitKey(0);
//	}
//}
//
//void Tester::testLFWA() {
//	std::string imageDirectory = "/home/zixuanwang/dataset/lfw2";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	boost::unordered_map<std::string, int> counter;
//	for (size_t i = 0; i < filenameArray.size(); ++i) {
//		counter[File::getParentDirectory(filenameArray[i])]++;
//	}
//	std::vector<RankItem<std::string, int> > rankList;
//	for (boost::unordered_map<std::string, int>::iterator iter =
//			counter.begin(); iter != counter.end(); ++iter) {
//		RankItem<std::string, int> rankItem(iter->first, -1 * iter->second);
//		rankList.push_back(rankItem);
//	}
//	std::sort(rankList.begin(), rankList.end());
//	for (size_t i = 0; i < 60; ++i) {
//		std::cout << rankList[i].index << std::endl;
//	}
//}
//
//void Tester::testHalf(){
//	std::string imageDirectory="c:/users/zixuan/desktop/tmp";
//	std::string outputDirectory="c:/users/zixuan/desktop/half";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray,imageDirectory, false);
//	for(size_t i=0;i<filenameArray.size();++i){
//		cv::Mat image=cv::imread(filenameArray[i],0);
//		int width=image.cols;
//		cv::Rect rect(0,0,width/2,image.rows);
//		cv::Mat half=image(rect);
//		cv::imwrite(outputDirectory+"/"+File::getFileName(filenameArray[i]),half);
//	}
//}
//
//void Tester::testVelocity(){
//	std::string imageDirectory="c:/users/zixuan/desktop/half";
//	std::ofstream outStream("c:/users/zixuan/desktop/imageVelocity.txt");
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray,imageDirectory,false);
//	RobustMatcher matcher;
//	VelocityComputer computer;
//	for(size_t i=0;i<filenameArray.size()-1;++i){
//		std::cout<<filenameArray[i]<<std::endl;
//		cv::Mat image1=cv::imread(filenameArray[i]);
//		cv::Mat image2=cv::imread(filenameArray[i+1]);
//		uint64_t startTime=boost::lexical_cast<uint64_t>(File::getFileStem(filenameArray[i]));
//		uint64_t endTime=boost::lexical_cast<uint64_t>(File::getFileStem(filenameArray[i+1]));
//		std::vector<cv::KeyPoint> keypointArray1;
//		std::vector<cv::KeyPoint> keypointArray2;
//		cv::Mat h=matcher.match(image1,image2,&keypointArray1,&keypointArray2);
//		if(!h.empty()){
//			//outStream<<(endTime+startTime)/2<<"\t"<<computer.compute(startTime,endTime,h)<<std::endl;
//			outStream<<(endTime+startTime)/2<<",";
//			std::ostream_iterator<double> outIter(outStream,",");
//			std::copy(h.ptr<double>(0),h.ptr<double>(0)+9,outIter);
//			outStream<<std::endl;
//		}
//		//matcher.show(image1,image2,keypointArray1,keypointArray2,"c:/users/zixuan/desktop/match/"+File::getFileStem(filenameArray[i])+File::getFileStem(filenameArray[i+1])+".jpg");
//	}
//	outStream.close();
//}
//
//void Tester::testCalibration(){
//	std::string imageDirectory="c:/users/zixuan/desktop/tmp";
//	std::vector<std::string> filelist;
//	File::getFiles(&filelist,imageDirectory);
//	CameraCalibrator calibrator;
//	cv::Size size1(9,6);
//	cv::Size size2(768,432);
//	calibrator.addChessboardPoints(filelist,size1);
//	calibrator.calibrate(size2);
//	cv::Mat cameraMatrix=calibrator.getCameraMatrix();
//	cv::Mat distCoeffs=calibrator.getDistCoeffs();
//	std::cout<<cameraMatrix<<std::endl;
//	std::cout<<distCoeffs<<std::endl;
//}
//
//void Tester::testSolvePnP(){
//	std::string dirPath="c:/users/zixuan/desktop/laptop_calibration";
//	//std::string dirPath="c:/users/zixuan/desktop/tablet_calibration";
//	//std::string templateImagePath="c:/users/zixuan/dropbox/microsoft/figure/learning_python4e.jpg";
//	std::string templateImagePath="c:/users/zixuan/dropbox/microsoft/figure/design.jpg";
//	CameraCalibrator calibrator;
//	std::vector<std::string> filelist;
//	File::getFiles(&filelist,dirPath);
//	cv::Size size1(9,6);
//	cv::Size size2(768,432);
//	calibrator.addChessboardPoints(filelist,size1);
//	calibrator.calibrate(size2);
//	//std::cout<<calibrator.getCameraMatrix()<<std::endl;
//	//std::cout<<calibrator.getDistCoeffs()<<std::endl;
//	PlanarObjectTracker tracker;
//	tracker.setIntrinsicMatrix(calibrator.getCameraMatrix());
//	tracker.setDistCoeffs(calibrator.getDistCoeffs());
//	tracker.loadTemplate(templateImagePath);
//
//	//// output object patches
//	//cv::Mat templateImage=cv::imread(templateImagePath);
//	//cv::Mat objectPoints=tracker.getObjectPoints();
//	//for(int i=0;i<objectPoints.rows;++i){
//	//	float* ptr=objectPoints.ptr<float>(i);
//	//	cv::Rect patchRect=tracker.getImageWindow(templateImage,ptr[0],ptr[1],8);
//	//	cv::Mat patch=templateImage(patchRect);
//	//	cv::imwrite("c:/users/zixuan/desktop/object_patches/"+boost::lexical_cast<std::string>(i)+".jpg",patch);
//	//}
//
//	cv::VideoCapture capture(0);
//	cv::Mat frame;
//	cv::Mat gray;
//	cv::namedWindow("frame");
//	cv::namedWindow("render");
//	cv::Mat warpImage;
//	Ticker ticker;
//	while(true){
//		capture>>frame;
//		//cv::cvtColor(frame,gray,CV_BGR2GRAY);
//		//cv::imwrite("c:/users/zixuan/desktop/"+boost::lexical_cast<std::string>(frameCounter++)+".jpg",gray);
//		//cv::Point point;
//		//tracker.zncc(gray,gray,&point);
//		if(!tracker.status()){
//			ticker.start();
//			tracker.initTrack(frame);
//			std::cout<<"initialization takes "<<ticker.stop()<<std::endl;
//		}else{
//			ticker.start();
//			tracker.track(frame);
//			std::cout<<"tracking takes "<<ticker.stop()<<std::endl;
//		}
//		if(tracker.status()){
//			tracker.drawProjectedCorners(frame);
//		}
//
//		//cv::Mat rvec=tracker.getRotationVec();
//		//cv::Mat tvec=tracker.getTranslationVec();
//		//std::cout<<rvec<<std::endl;
//		//std::cout<<tvec<<std::endl;
//		if(tracker.status()){
//			warpImage=tracker.warpTemplateImage(frame.size());
//			//cv::imshow("render",tracker.selectPyramidImage());
//			cv::imshow("render",warpImage);
//		}else{
//			cv::imshow("render",cv::Mat::zeros(frame.size(),CV_8UC1));
//		}
//		cv::imshow("frame",frame);
//		char c=cv::waitKey(30);
//		switch (c)
//		{
//		case 'd':
//			if(!tracker.getDebugMode()){
//				tracker.enableDebug();
//			}else{
//				tracker.disableDebug();
//			}
//			break;
//		}
//	}
//}
//
//void Tester::testCapture(){
//	cv::VideoCapture capture(0);
//	cv::Mat frame;
//	cv::namedWindow("frame");
//	int frameCount=0;
//	while(true){
//		capture>>frame;
//		cv::imwrite("c:/users/zixuan/desktop/calibration/"+boost::lexical_cast<std::string>(frameCount++)+".jpg",frame);
//		cv::imshow("frame",frame);
//		if(cv::waitKey(30) >= 0) break;
//	}
//}
//
//void Tester::testFace(){
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	CascadeDetector faceDetector;
//	CascadeDetector noseDetector;
//	faceDetector.init(cascadeName);
//	noseDetector.init(nestedCascadeName);
//
//	std::string imageDirectory="C:/Users/zxwang/Desktop/data";
//	std::string imageOutputDirectory="F:/data/image/pubfig_flickr";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray,imageDirectory,true);
//	for(size_t i=0;i<filenameArray.size();++i){
//		bool faceFound=false;
//		std::string filename=filenameArray[i];
//		cv::Mat image = cv::imread(filename, 0);
//		std::vector<cv::Rect> faceArray;
//		faceDetector.detect(&faceArray, image);
//		if(faceArray.empty()){
//			continue;
//		}
//		for(size_t j=0;j<faceArray.size();++j){
//			std::vector<cv::Rect> noseArray;
//			noseDetector.detect(&noseArray, image(faceArray[j]));
//			if(noseArray.size()==1){
//				faceFound=true;
//				break;
//			}
//		}
//		if(faceFound){
//			// output the face image
//			cv::Mat colorImage=cv::imread(filename);
//			std::string name=File::getFileName(filename);
//			std::string stem=File::getFileStem(filename);
//			std::string folderName=File::getParentDirectory(filename);
//			std::string folderPath=File::getParentDirectoryPath(filename);
//			std::string outDir=imageOutputDirectory+"/"+folderName;
//			boost::filesystem::create_directories(outDir);
//			cv::imwrite(outDir+"/"+name,colorImage);
//			boost::filesystem::copy_file(folderPath+"/"+stem+".json",outDir+"/"+stem+".json");
//			std::cout<<"In "<<filename<<" face is detected."<<std::endl;
//		}
//	}
//}
//
//void Tester::testLocation(){
//	std::string imageDirectory="C:/Users/zxwang/Dropbox/data";
//	std::ofstream outStream("C:/Users/zxwang/Dropbox/data/gt/location_must.txt");
//	RobustMatcher matcher;
//	cv::Ptr<cv::FeatureDetector> pDetector=new cv::OrbFeatureDetector(200);
//	cv::Ptr<cv::DescriptorExtractor> pDescriptor=new cv::OrbDescriptorExtractor();
//	matcher.setFeatureDetector(pDetector);
//	matcher.setDescriptorExtractor(pDescriptor);
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray,imageDirectory);
//	for(size_t i=0;i<filenameArray.size();++i){
//		cv::Mat image1=cv::imread(filenameArray[i],0);
//		if(image1.empty()){
//			continue;
//		}
//		for(size_t j=i+1;j<filenameArray.size();++j){
//			cv::Mat image2=cv::imread(filenameArray[j],0);
//			if(image2.empty()){
//				continue;
//			}
//			std::vector<cv::KeyPoint> keypointArray1;
//			std::vector<cv::KeyPoint> keypointArray2;
//			cv::Mat h=matcher.match(image1,image2,&keypointArray1,&keypointArray2);
//			if(!h.empty()){
//				outStream<<File::getFileName(filenameArray[i])<<"\t"<<File::getFileName(filenameArray[j])<<std::endl;
//			}
//		}
//		std::cout<<filenameArray[i]<<std::endl;
//	}
//	outStream.close();
//}
//
//void Tester::testFaceFeature(){
//	std::string cascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
//	std::string nestedCascadeName =
//			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
//	CascadeDetector faceDetector;
//	CascadeDetector noseDetector;
//	faceDetector.init(cascadeName);
//	noseDetector.init(nestedCascadeName);
//	Evaluation eval;
//	FaceLandmarkDetector::instance()->init("C:/Users/zxwang/Dropbox/microsoft/backup/flandmark_model.dat");
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray,"C:/Users/zxwang/Dropbox/www2013/data/pubfig_flickr",true);
//	// output two files
//	std::ofstream gtStream("C:/Users/zxwang/Desktop/face_gt.txt");
//	std::ofstream featureStream("C:/Users/zxwang/Desktop/face_feature.txt");
//	for(size_t i=0;i<filenameArray.size();++i){
//		std::string name=File::getParentDirectory(filenameArray[i]);
//		int label=eval.getLabel(name);
//		Sample sample=eval.extract(faceDetector,noseDetector,filenameArray[i]);
//		if(!sample.empty()){
//			std::string sampleString;
//			sample.save(&sampleString);
//			gtStream<<filenameArray[i]<<","<<label<<std::endl;
//			featureStream<<sampleString<<std::endl;
//		}
//		std::cout<<"Processing "<<filenameArray[i]<<std::endl;
//	}
//	gtStream.close();
//	featureStream.close();
//}
//
//void Tester::testLocationCluster(){
//	std::string dataDirectory="C:/Users/zxwang/Dropbox/www2013/data/pubfig_flickr";
//	std::ifstream inStream("C:/Users/zxwang/Desktop/face_gt.txt");
//	std::ofstream outStream("C:/Users/zxwang/Desktop/location_gt.txt");
//	std::vector<std::string> imageArray;
//	std::string line;
//	int clusterCount = 100;
//	KernelKmeansClusterer kkc(clusterCount,10);
//	srand((unsigned int)time(NULL));
//
//	while(getline(inStream,line)){
//		std::vector<std::string> tokenArray;
//		boost::split(tokenArray, line, boost::is_any_of(","));
//		std::string fileStemPath = File::getFileStemPath(tokenArray[0]);
//		imageArray.push_back(tokenArray[0]);
//		std::string jsonPath = fileStemPath + ".json";
//		boost::property_tree::ptree pt;
//		boost::property_tree::read_json(jsonPath,pt);
//		float longitude=pt.get<float>("photo.location.longitude");
//		float latitude=pt.get<float>("photo.location.latitude");
//		Sample sample(2);
//		sample[0]=longitude;
//		sample[1]=latitude;
//		kkc.addSample(sample);
//	}
//	kkc.initialize();
//	kkc.cluster();
//	std::vector<int> labelArray = kkc.labelArray();
//	for(size_t i=0;i<labelArray.size();++i){
//		outStream<<imageArray[i]<<","<<labelArray[i]<<std::endl;
//	}
//	inStream.close();
//	outStream.close();
//}
//
//void Tester::testLocationFeature(){
//	std::ifstream inStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_gt.txt");
//	std::ofstream outStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_feature.txt");
//	Vocabulary::instance()->load("C:/Users/zxwang/Desktop/voc_1k.dat");
//	std::string line;
//	while(getline(inStream,line)){
//		std::vector<std::string> tokenArray;
//		boost::split(tokenArray, line, boost::is_any_of(","));
//		std::string filename=tokenArray[0];
//		cv::Mat image=cv::imread(filename,0);
//		Sample bowSample=BoWDescriptor::instance()->compute(image);
//		image=cv::imread(filename,1);
//		Sample colorSample=ColorDescriptor::instance()->compute(image);
//		outStream<<bowSample<<","<<colorSample<<std::endl;
//	}
//	inStream.close();
//	outStream.close();
//}
//
//void Tester::testVocabulary(){
//	std::string imageDirectory="C:/Users/zxwang/Dropbox/www2013/data/pubfig_flickr";
//	std::vector<std::string> filenameArray;
//	File::getFiles(&filenameArray, imageDirectory, true);
//	std::vector<float> sampleArray;
//	int sampleCount=0;
//	for(size_t i=0;i<filenameArray.size();++i){
//		std::string ext=File::getFileExtension(filenameArray[i]);
//		if(ext==".jpg"){
//			cv::Mat image=cv::imread(filenameArray[i],0);
//			std::vector<cv::KeyPoint> keypoint;
//			cv::Mat descriptor;
//			BoWDescriptor::instance()->extractDescriptor(&keypoint,&descriptor,image);
//			std::copy(descriptor.ptr<float>(0),descriptor.ptr<float>(0)+descriptor.rows*descriptor.cols,std::back_inserter(sampleArray));
//			sampleCount+=descriptor.rows;
//		}
//	}
//	cv::Mat sampleMat(sampleArray,false);
//	sampleMat=sampleMat.reshape(0,sampleCount);
//	Vocabulary::instance()->build(sampleMat,1000);
//	Vocabulary::instance()->save("C:/Users/zxwang/Desktop/voc_1k.dat");
//}
//
//void Tester::testMustLink(){
//	std::ifstream gtStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_gt.txt");
//	std::string gtLine;
//	std::vector<std::string> filenameArray;
//	while(getline(gtStream,gtLine)){
//		std::vector<std::string> tokenArray;
//		boost::split(tokenArray, gtLine, boost::is_any_of(","));
//		filenameArray.push_back(tokenArray[0]);
//	}
//	std::ofstream outStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_must.txt");
//
//	std::ifstream featureStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_feature.txt");
//	std::string line;
//	KnnClassifier knn;
//	std::vector<Sample> sampleArray;
//	int i=0;
//	while(getline(featureStream,line)){
//		Sample sample;
//		sample.load(line);
//		knn.addSample(sample,i++);
//		sampleArray.push_back(sample);
//	}
//	knn.build();
//	RobustMatcher matcher;
//	for(size_t i=0;i<sampleArray.size();++i){
//		std::vector<int> resultArray=knn.query(sampleArray[i],50);
//		cv::Mat image1=cv::imread(filenameArray[i],0);
//		if(image1.empty()){
//			continue;
//		}
//		for(size_t j=1;j<resultArray.size();++j){
//			cv::Mat image2=cv::imread(filenameArray[resultArray[j]],0);
//			if(image2.empty()){
//				continue;
//			}
//			std::vector<cv::KeyPoint> keypointArray1;
//			std::vector<cv::KeyPoint> keypointArray2;
//			cv::Mat h=matcher.match(image1,image2,&keypointArray1,&keypointArray2);
//			if(!h.empty() && keypointArray1.size()>=10){
//				if(i!=resultArray[j]){
//					outStream<<i<<","<<resultArray[j]<<std::endl;
//				}
//				//std::cout<<keypointArray1.size()<<std::endl;
//				//cv::Mat color1=cv::imread(filenameArray[i]);
//				//cv::Mat color2=cv::imread(filenameArray[resultArray[j]]);
//				//matcher.show(color1,color2,keypointArray1,keypointArray2);
//			}
//			std::cout<<"matching "<<i<<" and "<<resultArray[j]<<std::endl;
//		}
//	}
//	featureStream.close();
//	gtStream.close();
//	outStream.close();
//}
//
//void Tester::testLocationBaseLine(){
//	// load feature
////	for(int clusterCount=10;clusterCount<=100;clusterCount+=10){
//	int clusterCount=100;
//		std::ifstream featureStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_feature.txt");
//		std::ifstream mustStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_must.txt");
//		RandIndexComputer ri;
//		ri.loadGroundTruth("C:/Users/zxwang/Dropbox/www2013/data/gt/location_gt.txt");
//		KernelKmeansClusterer kkc(clusterCount,10);
//		std::string line;
//		while(getline(featureStream,line)){
//			Sample sample;
//			featureStream>>sample;
//			sample.normalize();
//			kkc.addSample(sample);
//		}
//		const std::vector<Sample>& sampleArray=kkc.sampleArray();
//		//SemiSupervisedKernel* pssk=new SemiSupervisedKernel(&sampleArray);
//		GaussianKernel *pgk=new GaussianKernel(&sampleArray);
//		// add constraints
//		/*while(getline(mustStream,line)){
//			std::vector<std::string> tokenArray;
//			boost::split(tokenArray, line, boost::is_any_of(","));
//			pssk->addMustLink(boost::lexical_cast<int>(tokenArray[0]),boost::lexical_cast<int>(tokenArray[1]));
//		}
//		pssk->processMustLink();
//		boost::shared_ptr<Kernel> pKernel(pssk);*/
//		boost::shared_ptr<Kernel> pKernel(pgk);
//		kkc.setKernel(pKernel);
//		kkc.initialize();
//		kkc.cluster();
//		std::vector<int> label=kkc.labelArray();
//		std::cout<<ri.compute(label)<<std::endl;
//		featureStream.close();
//		mustStream.close();
//	//}
//}
//
//void Tester::testFaceBaseLine(){
//	// load feature
//	for(int clusterCount=10;clusterCount<140;clusterCount+=10){
//		std::ifstream featureStream("C:/Users/zxwang/Dropbox/www2013/data/gt/face_feature.txt");
//		RandIndexComputer ri;
//		ri.loadGroundTruth("C:/Users/zxwang/Dropbox/www2013/data/gt/face_gt.txt");
//		KernelKmeansClusterer kkc(clusterCount,10);
//		std::string line;
//		while(getline(featureStream,line)){
//			Sample sample;
//			featureStream>>sample;
//			sample.normalize();
//			kkc.addSample(sample);
//		}
//		const std::vector<Sample>& sampleArray=kkc.sampleArray();
//		LinearKernel* plk=new LinearKernel(&sampleArray);
//		boost::shared_ptr<Kernel> pKernel(plk);
//		kkc.setKernel(pKernel);
//		kkc.initialize();
//		kkc.cluster();
//		std::vector<int> label=kkc.labelArray();
//		std::cout<<ri.compute(label)<<std::endl;
//		featureStream.close();
//	}
//}
//
//void Tester::testCoclustering(){
//	std::ifstream locationFeatureStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_feature.txt");
//	std::ifstream locationMustStream("C:/Users/zxwang/Dropbox/www2013/data/gt/location_must.txt");
//	KernelKmeansClusterer locationKkc(100,10);
//	std::string line;
//	while(getline(locationFeatureStream,line)){
//		Sample sample;
//		locationFeatureStream>>sample;
//		sample.normalize();
//		locationKkc.addSample(sample);
//	}
//	std::vector<Sample>& locationSampleArray=locationKkc.sampleArray();
//	SemiSupervisedKernel* pssk=new SemiSupervisedKernel(&locationSampleArray);
//	//SemiSupervisedKernel ssk(&sampleArray);
//	// add constraints
//	while(getline(locationMustStream,line)){
//		std::vector<std::string> tokenArray;
//		boost::split(tokenArray, line, boost::is_any_of(","));
//		pssk->addMustLink(boost::lexical_cast<int>(tokenArray[0]),boost::lexical_cast<int>(tokenArray[1]));
//	}
//	pssk->processMustLink();
//	boost::shared_ptr<Kernel> pLKernel(pssk);
//	locationKkc.setKernel(pLKernel);
//	locationKkc.initialize();
//	locationKkc.cluster();
//	locationFeatureStream.close();
//	locationMustStream.close();
//
//
//	std::ifstream faceFeatureStream("C:/Users/zxwang/Dropbox/www2013/data/gt/face_feature.txt");
//	RandIndexComputer ri;
//	ri.loadGroundTruth("C:/Users/zxwang/Dropbox/www2013/data/gt/face_gt.txt");
//	KernelKmeansClusterer kkc(132,10);
//	while(getline(faceFeatureStream,line)){
//		Sample sample;
//		faceFeatureStream>>sample;
//		sample.normalize();
//		kkc.addSample(sample);
//	}
//	std::vector<Sample>& faceSampleArray=kkc.sampleArray();
//	LinearKernel* plk=new LinearKernel(&faceSampleArray);
//	boost::shared_ptr<Kernel> pKernel(plk);
//	kkc.setKernel(pKernel);
//	kkc.initialize();
//	kkc.cluster();
//	//std::vector<int> label=kkc.labelArray();
//	//std::cout<<ri.compute(label)<<std::endl;
//	faceFeatureStream.close();
//
//	// process possible links
//	std::vector<int> locationLabel=locationKkc.labelArray();
//	std::vector<int> faceLabel=kkc.labelArray();
//
//	// count the number of people at each location
//	boost::unordered_map<int, boost::unordered_set<int> > locationPeopleMap;
//	boost::unordered_map<int, boost::unordered_set<int> > locationIdMap;
//	for(size_t i=0;i<locationLabel.size();++i){
//		locationPeopleMap[locationLabel[i]].insert(faceLabel[i]);
//		locationIdMap[locationLabel[i]].insert((int)i);
//	}
//	// add possible links
//	SemiSupervisedKernel* pfssk=new SemiSupervisedKernel(&faceSampleArray);
//	for(boost::unordered_map<int, boost::unordered_set<int> >::iterator iter=locationIdMap.begin();iter!=locationIdMap.end();++iter){
//		boost::unordered_set<int>& peopleSet=locationPeopleMap[iter->first];
//		float weight=0.0f;
//		if(!peopleSet.empty()){
//			weight=log(132.0f/(float)peopleSet.size())/log(132.0f);
//		}
//		boost::unordered_set<int>& idSet=iter->second;
//		for(boost::unordered_set<int>::iterator iter1=idSet.begin();iter1!=idSet.end();++iter1){
//			boost::unordered_set<int>::iterator iter2=iter1;
//			++iter2;
//			for(;iter2!=idSet.end();++iter2){
//				pfssk->addPossibleLink(*iter1,*iter2,weight);
//			}
//		}
//	}
//	boost::shared_ptr<Kernel> pFKernel(pfssk);
//	kkc.setKernel(pFKernel);
//	kkc.initialize();
//	kkc.cluster();
//	std::vector<int> label=kkc.labelArray();
//	std::cout<<ri.compute(label)<<std::endl;
//}

void Tester::testVideo() {
	cv::VideoCapture cap(0);
	if (!cap.isOpened()) {
		std::cerr << "Error in opening video" << std::endl;
		exit(1);
	}
	std::string cascadeName =
			"C:/opencv/data/haarcascades/haarcascade_frontalface_alt2.xml";
	std::string nestedCascadeName =
			"C:/opencv/data/haarcascades/haarcascade_mcs_nose.xml";
	// initialize detectors
	CascadeDetector faceDetector;
	CascadeDetector noseDetector;
	faceDetector.init(cascadeName);
	noseDetector.init(nestedCascadeName);
	HeartRateComputer heartComputer;
	heartComputer.setFaceDetector(&faceDetector, &noseDetector);
	cv::Mat frame;
	cv::namedWindow("edges", 1);
	for (;;) {
		cap >> frame; // get a new frame from camera
		heartComputer.captureFrame(frame);
		cv::imshow("edges", frame);
		if (cv::waitKey(30) >= 0)
			break;
	}
}
