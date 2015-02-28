#include <fcntl.h>
#include <unistd.h>
#include <cstring>
#include <vector>
#include <cstdio>

using namespace std;

#ifdef DEBUG
#define _(x) x;
#else
#define _(x) ;
#endif


// Compute some code file stats
class FileStat {
private:
	// the file name of path
    const char* filename;
    // the file descriptor to open the file
    int fd;
    // the buffer containing all the file
    char* buffer;
    // the size of the file
    int filesize;
    // the maximum size of the file
    const static int MAX_SIZE = 10000000;

    typedef pair<int,bool> ib;

    struct automa_state {
    	// the position in the file
        int position;
        // the number of the line
        int lineNumber;
        // the number of indentation chars in this line
        int indentNumber;
        // the type of indentation (bitmask). 1=tab 2=space
        char indentType;
        // if a non-space char is present since now in this line
        bool hasChars;
        // if the current char is in a string
        bool stringMode;
        // if the current char is in a comment
        bool commentMode;
        bool weakCommentMode;

        // stack of open pars.
        // <line_number,type> type: true=endline, false=begline
        vector<ib> par_pos;
    };

	// the current state of the automa
    automa_state state;

    ///
    /// FILE STATISTICS
    ///

    // # of { at end of line
    int par_endline;
    // # of { at beggining of line
    int par_begline;
    // # of inline { }
    int par_inline;

	// # of tab-indented lines
    int ind_tab;
    // # of space-indented lines
    int ind_spa;
    // # of tab-and-space-indented lines
    int ind_mix;

	int par_spaced;
	int par_unspaced;

	// # of empty lines
	int white_lines;
	int indented_lines;


	void init();

public:

    struct stat_t {
	    // # of { at end of line
		int par_endline;
		// # of { at beggining of line
		int par_begline;
		// # of inline { }
		int par_inline;

		// # of tab-indented lines
		int ind_tab;
		// # of space-indented lines
		int ind_spa;
		// # of tab-and-space-indented lines
		int ind_mix;

		// # of pars with/out space
		int par_spaced;
		int par_unspaced;

		// # of empty lines
		int white_lines;
		int indented_lines;

		// # of lines
		int lines, file_size;
    };

    FileStat(const char* filename);
    ~FileStat();

	// Read the file using a fast method
    void Read();
    // Compute the statistics using an automa
    void Compute();

	// Return the computed statistics
    stat_t GetStat();
};
