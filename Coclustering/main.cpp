#include "Tester.h"
int main(int argc, char* argv[]) {
//	for (int i = 0; i < 7; ++i) {
//		std::string label = "l" + boost::lexical_cast<std::string>(i);
//		std::vector<std::string> filenameArray = Evaluation::faceFilter(
//				"/home/zixuanwang/dataset/lfw2",
//				"/home/zixuanwang/Desktop/lfwa_location/" + label + ".txt");
//		Serializer::saveStringArray(filenameArray,
//				"/home/zixuanwang/Desktop/lfwa_location/" + label + ".all");
//	}
	std::vector<std::string> array;
	Serializer::loadStringArray(array,
			"/home/zixuanwang/Desktop/lfwa_location/l5.all");
	std::vector<std::string> trainArray;
	std::vector<std::string> testArray;
	Evaluation::split(&trainArray, &testArray, array, 0.9);
	std::cout << "Train size: " << trainArray.size() << std::endl;
	std::cout << "Test size: " << testArray.size() << std::endl;
	std::string path = "/home/zixuanwang/Desktop/l5";
	Evaluation::train(trainArray, path);
	Evaluation::test(testArray, path);
//	Tester::testLFWA();
	return 0;
}
