#include <iostream>

#include "file.h"

using namespace std;

int main(int argc, char** argv) {
    FileStat file(argc==2?argv[1]:"testfile.cpp");
    file.Read();
    file.Compute();

    FileStat::stat_t stat = file.GetStat();
    printf("%15s: %d\n", "par_endline", stat.par_endline);
	printf("%15s: %d\n", "par_begline", stat.par_begline);
	printf("%15s: %d\n", "par_inline", stat.par_inline);
	printf("%15s: %d\n", "ind_tab", stat.ind_tab);
	printf("%15s: %d\n", "ind_spa", stat.ind_spa);
	printf("%15s: %d\n", "ind_mix", stat.ind_mix);
	printf("%15s: %d\n", "par_spaced", stat.par_spaced);
	printf("%15s: %d\n", "par_unspaced", stat.par_unspaced);
	printf("%15s: %d\n", "white_lines", stat.white_lines);
	printf("%15s: %d\n", "indented_lines", stat.indented_lines);
	printf("%15s: %d\n", "lines", stat.lines);
	printf("%15s: %d\n", "bytes", stat.file_size);
}
