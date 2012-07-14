#pragma once
#include <boost/filesystem.hpp>
class File {
public:
	File();
	~File();
	static void getFiles(std::vector<std::string>* pFileArray,
			const std::string& directory, bool recursive = false);
	static std::string getParentDirectory(const std::string& filepath);
	static std::string getParentDirectoryPath(const std::string& filepath);
	static std::string getFileName(const std::string& filepath);
	static std::string getFileStem(const std::string& filepath);
};


