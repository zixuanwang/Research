#pragma once

#include <boost/unordered_map.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <opencv2/opencv.hpp>
#include <sstream>
#include <fstream>
#include <string>

// This class is used to serialize a bunch of data structures.
class Serializer {
public:
	Serializer();
	~Serializer();
	static void load(cv::Mat& mat, const std::string& path) {
		mat = cv::Mat();
		std::ifstream inStream;
		inStream.open(path.c_str(), std::ios::binary);
		if (inStream.good()) {
			int rows;
			int cols;
			int type;
			inStream.read((char*) &rows, sizeof(rows));
			inStream.read((char*) &cols, sizeof(cols));
			inStream.read((char*) &type, sizeof(type));
			mat = cv::Mat(rows, cols, type);
			size_t length = (size_t) rows * mat.step;
			inStream.read((char*) mat.data, length);
			inStream.close();
		}
	}

	static void save(const cv::Mat& mat, const std::string& path) {
		if (mat.empty()) {
			return;
		}
		std::ofstream outStream;
		outStream.open(path.c_str(), std::ios::binary);
		if (outStream.good()) {
			int rows = mat.rows;
			int cols = mat.cols;
			int type = mat.type();
			outStream.write((char*) &rows, sizeof(rows));
			outStream.write((char*) &cols, sizeof(cols));
			outStream.write((char*) &type, sizeof(type));
			size_t length = (size_t) rows * mat.step;
			outStream.write((char*) mat.data, length);
			outStream.close();
		}
	}

	template<class T> static void load(std::vector<T>& array,
			const std::string& path) {
		array.clear();
		std::ifstream inStream;
		inStream.open(path.c_str(), std::ios::binary);
		if (inStream.good()) {
			size_t size;
			inStream.read((char*) &size, sizeof(size));
			array.assign(size, 0);
			inStream.read((char*) &array[0], sizeof(T) * size);
			inStream.close();
		}
	}
	template<class T> static void save(const std::vector<T>& array,
			const std::string& path) {
		if (array.empty()) {
			return;
		}
		std::ofstream outStream;
		outStream.open(path.c_str(), std::ios::binary);
		if (outStream.good()) {
			size_t size = array.size();
			outStream.write((char*) &size, sizeof(size));
			outStream.write((char*) &array[0], sizeof(T) * size);
			outStream.close();
		}
	}

	template<class T, class U> static void load(boost::unordered_map<T, U>& map,
			const std::string& path) {
		map.clear();
		std::ifstream inStream;
		inStream.open(path.c_str(), std::ios::binary);
		if (inStream.good()) {
			size_t size;
			inStream.read((char*) &size, sizeof(size));
			for (size_t i = 0; i < size; ++i) {
				T key;
				U value;
				inStream.read((char*) &key, sizeof(key));
				inStream.read((char*) &value, sizeof(value));
				map[key] = value;
			}
			inStream.close();
		}
	}

	template<class T, class U> static void save(
			const boost::unordered_map<T, U>& map, const std::string& path) {
		if (map.empty()) {
			return;
		}
		std::ofstream outStream;
		outStream.open(path.c_str(), std::ios::binary);
		if (outStream.good()) {
			size_t size = map.size();
			outStream.write((char*) &size, sizeof(size));
			for (typename boost::unordered_map<T, U>::const_iterator iter =
					map.begin(); iter != map.end(); ++iter) {
				T key = iter->first;
				U value = iter->second;
				outStream.write((char*) &key, sizeof(key));
				outStream.write((char*) &value, sizeof(value));
			}
			outStream.close();
		}
	}

	static void loadLandmark(std::vector<cv::Point2f>& landmarkArray,
			const std::string& path) {
		landmarkArray.clear();
		std::ifstream inStream;
		inStream.open(path.c_str());
		if (inStream.good()) {
			std::string line;
			while (getline(inStream, line)) {
				std::stringstream ss;
				ss << line;
				float x, y;
				ss >> x >> y;
				landmarkArray.push_back(cv::Point2f(x, y));
			}
			inStream.close();
		}
	}

	static void saveLandmark(const std::vector<cv::Point2f>& landmarkArray,
			const std::string& path) {
		if (landmarkArray.empty()) {
			return;
		}
		std::ofstream outStream;
		outStream.open(path.c_str());
		if (outStream.good()) {
			for (size_t i = 0; i < landmarkArray.size(); ++i) {
				outStream << landmarkArray[i].x << "\t" << landmarkArray[i].y
						<< std::endl;
			}
			outStream.close();
		}
	}

	static void saveStringMap(const boost::unordered_map<std::string, int>& map, const std::string& path){
		if(map.empty()){
			return;
		}
		std::ofstream outStream;
		outStream.open(path.c_str());
		if (outStream.good()) {
			for(boost::unordered_map<std::string, int>::const_iterator iter=map.begin();iter!=map.end();++iter){
				outStream<<iter->first<<"\t"<<iter->second<<std::endl;
			}
			outStream.close();
		}
	}

	static void loadStringMap(boost::unordered_map<std::string, int>& map, const std::string& path){
		map.clear();
		std::ifstream inStream;
		inStream.open(path.c_str());
		if(inStream.good()){
			std::string line;
			while (getline(inStream, line)) {
				std::vector<std::string> tokenArray;
				boost::split(tokenArray, line, boost::is_any_of("\t"));
				if(tokenArray.size()==2){
					map[tokenArray[0]]=boost::lexical_cast<int>(tokenArray[1]);
				}
			}
			inStream.close();
		}
	}
};

