#pragma once

#include <boost/unordered_map.hpp>
#include <opencv2/opencv.hpp>
#include <fstream>
#include <string>

// This class is used to searilze a bunch of data structures.
class Serializer {
public:
	Serializer();
	~Serializer();
	static void load(cv::Mat* pMat, const std::string& path) {
		*pMat = cv::Mat();
		std::ifstream inStream;
		inStream.open(path.c_str(), std::ios::binary);
		if (inStream.good()) {
			int rows;
			int cols;
			int type;
			inStream.read((char*) &rows, sizeof(rows));
			inStream.read((char*) &cols, sizeof(cols));
			inStream.read((char*) &type, sizeof(type));
			*pMat = cv::Mat(rows, cols, type);
			size_t length = (size_t) rows * pMat->step;
			inStream.read((char*) pMat->data, length);
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

	template<class T> static void load(std::vector<T>* pArray,
			const std::string& path) {
		pArray->clear();
		std::ifstream inStream;
		inStream.open(path.c_str(), std::ios::binary);
		if (inStream.good()) {
			size_t size;
			inStream.read((char*) &size, sizeof(size));
			pArray->assign(size, 0);
			inStream.read((char*) &(*pArray)[0], sizeof(T) * size);
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

	template<class T, class U> static void load(boost::unordered_map<T, U>* pMap
			, const std::string& path) {
		pMap->clear();
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
				(*pMap)[key] = value;
			}
			inStream.close();
		}
	}

	template<class T, class U> static void save(
			const boost::unordered_map<T, U>& map,
			const std::string& path) {
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
};

