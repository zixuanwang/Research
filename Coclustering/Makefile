CFLAGS = -O3 -Wall

OBJS = BoWDescriptor.o flandmark_detector.o IlluminationNormalizer.o PCACompressor.o CascadeDetector.o GaussianKernel.o RandIndexComputer.o Classifier.o ImageResizer.o RobustMatcher.o Clusterer.o Kernel.o Sample.o ColorDescriptor.o KernelKmeansClusterer.o SemiSupervisedKernel.o Evaluation.o KnnClassifier.o Serializer.o FaceDescriptor.o liblbp.o SVMClassifier.o FaceDetector.o LinearKernel.o Tester.o FaceLandmarkDetector.o main.o Vocabulary.o File.o PatchExtractor.o

LIBS = -lboost_system -lboost_filesystem -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_features2d -lopencv_ml -lopencv_nonfree -lopencv_calib3d -lopencv_video -lopencv_videostab -lopencv_ts -lopencv_flann -lopencv_objdetect -lboost_thread -lboost_program_options

TARGET = Cocluster

$(TARGET):	$(OBJS)
	g++ -o $(TARGET) $(LIBS) $(OBJS)

%.o: %.cpp %.h
	g++ -c -o $@ $< $(CFLAGS) 

all:	$(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)
