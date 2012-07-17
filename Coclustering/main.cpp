#include "Tester.h"
int main(int argc, char* argv[]){
	std::vector<std::string> array;
	Serializer::loadStringArray(array,"C:/Users/t-ziwan/Desktop/location/l6.train");
	std::vector<std::string> trainArray;
	std::vector<std::string> testArray;
	Evaluation::split(&trainArray,&testArray,array,0.9);
	std::cout<<"Train size: "<<trainArray.size()<<std::endl;
	std::cout<<"Test size: "<<testArray.size()<<std::endl;
	std::string path="C:/Users/t-ziwan/Desktop/test/l6";
	Evaluation::train(trainArray,path);
	Evaluation::test(testArray,path);
	getchar();
	return 0;
}