#pragma once
#include <boost/filesystem.hpp>

// this class defines a set of file operations.
class File {
public:
	File();
	~File();
	// get all files in a directory
	static void getFiles(std::vector<std::string>* pFileArray,
			const std::string& directory, bool recursive = false);
	// /usr/bin/foo.txt returns bin
	static std::string getParentDirectory(const std::string& filepath);
	// /usr/bin/foo.txt returns /usr/bin
	static std::string getParentDirectoryPath(const std::string& filepath);
	// /usr/bin/foo.txt returns foo.txt
	static std::string getFileName(const std::string& filepath);
	// /usr/bin/foo.txt returns foo
	static std::string getFileStem(const std::string& filepath);
};

