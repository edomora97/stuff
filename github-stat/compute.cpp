#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <dirent.h>
#include <string>
#include <cstring>
#include <vector>
#include <ctime>

#include "file.h"

using namespace std;

typedef long long int64;

struct global_stats_t {
	int par_endline;
	int par_begline;
	int par_inline;
	int ind_tab;
	int ind_spa;
	int ind_mix;
	int par_spaced;
	int par_unspaced;
	int white_lines;
	int indented_lines;
	int lines;
	int64 bytes;
};

string extensions[] = {
	".c",
	".cpp",
	".h",
	".rb",
	".cs",
	".php",
	".py",
	".hpp",
	".js",
	".css",
	".java"
};

vector<string> files;

global_stats_t global_stats;


bool isFileNameValid(char* fileName) {
	// Makefile
	if (!strcmp(fileName, "Makefile")) return true;

	char *dot = strrchr(fileName, '.');
	if (!dot) return false;

	for (int i = 0; i < sizeof(extensions)/8; i++)
		if (!strcmp(dot, extensions[i].c_str()))
			return true;

	return false;
}

void process(const char* fileName) {
	FileStat file(fileName);
	file.Read();
	file.Compute();

	FileStat::stat_t stat = file.GetStat();
	global_stats.par_endline += stat.par_endline;
	global_stats.par_begline += stat.par_begline;
	global_stats.par_inline += stat.par_inline;
	global_stats.ind_tab += stat.ind_tab;
	global_stats.ind_spa += stat.ind_spa;
	global_stats.ind_mix += stat.ind_mix;
	global_stats.par_spaced += stat.par_spaced;
	global_stats.par_unspaced += stat.par_unspaced;
	global_stats.white_lines += stat.white_lines;
	global_stats.indented_lines += stat.indented_lines;
	global_stats.lines += stat.lines;
	global_stats.bytes += stat.file_size;
}

void browseDir(string path) {
	DIR* dir = opendir(path.c_str());
	if (!dir) return;
	dirent* dp;
	while ((dp = readdir(dir)) != NULL) {
		string fileName = path + "/" + dp->d_name;
		char* cFileName = (char*)fileName.c_str();

		// if it is a directory
		if (dp->d_type == DT_DIR) {
			// skip the dirs that starts with .
			if (dp->d_name[0] != '.')
				browseDir(fileName);
		}
		// if it is a file
		else if (dp->d_type == DT_REG)
			if (isFileNameValid(cFileName))
				files.push_back(fileName);
	}
	closedir(dir);
}

int main(int argc, char** argv) {
	if (argc != 2) {
		fprintf(stderr, "usage: %s DIR\n", argv[0]);
		exit(1);
	}

	char* path = argv[1];

	clock_t start = clock();


	browseDir(path);


	clock_t time_browseDir = clock();

	size_t size = files.size();

	fprintf(stderr, " -----> %s \n", path);
	fprintf(stderr, "# of files: %lu\n", size);

	int gap = size / 1000;
	if (gap == 0) gap = 1;

	for (int i = 0; i < size; i++) {
		process(files[i].c_str());
		if (i && i % gap == 0)	   fprintf(stderr, ".");
		if (i && i % (gap*100) == 0) fprintf(stderr, "\n");
	}
	fprintf(stderr, "\n");

	clock_t time_computation = clock();

	fprintf(stderr, "%15s: %d\n", "par_endline", global_stats.par_endline);
	fprintf(stderr, "%15s: %d\n", "par_begline", global_stats.par_begline);
	fprintf(stderr, "%15s: %d\n", "par_inline", global_stats.par_inline);
	fprintf(stderr, "%15s: %d\n", "ind_tab", global_stats.ind_tab);
	fprintf(stderr, "%15s: %d\n", "ind_spa", global_stats.ind_spa);
	fprintf(stderr, "%15s: %d\n", "ind_mix", global_stats.ind_mix);
	fprintf(stderr, "%15s: %d\n", "par_spaced", global_stats.par_spaced);
	fprintf(stderr, "%15s: %d\n", "par_unspaced", global_stats.par_unspaced);
	fprintf(stderr, "%15s: %d\n", "white_lines", global_stats.white_lines);
	fprintf(stderr, "%15s: %d\n", "indented_lines", global_stats.indented_lines);
	fprintf(stderr, "%15s: %d\n", "lines", global_stats.lines);
	fprintf(stderr, "%15s: %llu\n", "bytes", global_stats.bytes);

	float setup_time = 1.0f*(time_browseDir-start)/CLOCKS_PER_SEC;
	float computation_time = 1.0f*(time_computation-time_browseDir)/CLOCKS_PER_SEC;
	float total_time = 1.0f*(time_computation-start)/CLOCKS_PER_SEC;

	fprintf(stderr, "time to search the files: %f sec\n", setup_time);
	fprintf(stderr, "time to compute:		: %f sec\n", computation_time);
	fprintf(stderr, "mean time per file	  : %f sec\n", computation_time/size);
	fprintf(stderr, "total time			  : %f sec\n", total_time);

	// write the data to the standard output
	fprintf(stdout, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%llu,%lu",
		global_stats.par_endline,
		global_stats.par_begline,
		global_stats.par_inline,
		global_stats.ind_tab,
		global_stats.ind_spa,
		global_stats.ind_mix,
		global_stats.par_spaced,
		global_stats.par_unspaced,
		global_stats.white_lines,
		global_stats.indented_lines,
		global_stats.lines,
		global_stats.bytes,
		size);
}
