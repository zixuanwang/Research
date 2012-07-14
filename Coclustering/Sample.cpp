#include "Sample.h"


Sample::Sample(void)
{
}

Sample::Sample(size_t dimension){
	mVector.assign(dimension,0.0f);
}

Sample::Sample(const std::vector<float>& vector){
	mVector.assign(vector.begin(),vector.end());
}

Sample::~Sample(void)
{
}

Sample Sample::operator+(const Sample& rhs) const{
	size_t dimension=size();
	Sample result(dimension);
	for(size_t i=0;i<dimension;++i){
		result[i]=mVector[i]+rhs[i];
	}
	return result;
}

Sample Sample::operator-(const Sample& rhs) const{
	size_t dimension=size();
	Sample result(dimension);
	for(size_t i=0;i<dimension;++i){
		result[i]=mVector[i]-rhs[i];
	}
	return result;
}

void Sample::operator*(float scale){
	std::transform(mVector.begin(),mVector.end(),mVector.begin(),std::bind1st(std::multiplies<float>(),scale));
}

float Sample::operator[](size_t index) const{
	if(index<mVector.size()){
		return mVector[index];
	}
	std::cerr<<	"Out of boundary"<<std::endl;
	exit(1);
}

float& Sample::operator[](size_t index){
	if(index<mVector.size()){
		return mVector[index];
	}
	std::cerr<<	"Out of boundary"<<std::endl;
	exit(1);
}

bool Sample::empty() const{
	return mVector.empty();
}

size_t Sample::size() const{
	return mVector.size();
}

float Sample::L2Norm(){
	double sum=0.0;
	for(size_t i=0;i<mVector.size();++i){
		sum+=mVector[i]*mVector[i];
	}
	return (float)sqrt(sum);
}

void Sample::normalize(){
	float n=L2Norm();
	if(n!=0.0f){
		std::transform(mVector.begin(),mVector.end(),mVector.begin(),std::bind2nd(std::divides<float>(),n));
	}
}

void Sample::print(){
	std::ostream_iterator<float> iter(std::cout,", ");
	std::copy(mVector.begin(),mVector.end(),iter);
}

const std::vector<float>& Sample::getData() const{
	return mVector;
}

void Sample::save(std::string* pString){
	if(empty()){
		return;
	}
	std::stringstream ss;
	for(size_t i=0;i<mVector.size()-1;++i){
		ss<<mVector[i]<<",";
	}
	ss<<mVector.back();
	*pString=ss.str();
}

void Sample::load(const std::string& string){
	mVector.clear();
	if(string.empty()){
		return;
	}
	std::vector<std::string> tokenArray;
	boost::split(tokenArray, string, boost::is_any_of(","));
	for(size_t i=0;i<tokenArray.size();++i){
		mVector.push_back(boost::lexical_cast<float>(tokenArray[i]));
	}
}