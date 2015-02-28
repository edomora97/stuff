#include "file.h"

using namespace std;

FileStat::FileStat(const char* filename) {
	this->filename = filename;
	this->fd = -1;
	this->buffer = new char[MAX_SIZE];
	init();
}
FileStat::~FileStat() {
	delete[] this->buffer;
}

void FileStat::Read() {
	fd = open(filename, O_RDONLY);
	filesize = read(fd, buffer, MAX_SIZE);
	close(this->fd);
}

void FileStat::Compute() {
	// reset the automa
	init();

	char current = '\0',
		 prev = '\0',
		 next = '\0';

	// read all the file
	while (state.position < filesize) {
		// the current char in the file
		prev = current;
		current = buffer[state.position];
		next = buffer[state.position+1];

		// indentation
		if (!state.hasChars && (current == '\t' || current == ' ')) {
			state.indentNumber++;
			if (current == '\t')
				state.indentType |= 1;
			if (current == ' ')
				state.indentType |= 2;

		// skip CR
		} else if (current == '\r') {

		// end line
		} else if (current == '\n') {
			// save indentation info
			if (state.indentType == 1)
				ind_tab++;
			if (state.indentType == 2)
				ind_spa++;
			if (state.indentType == 3)
				ind_mix++;

			if (state.hasChars == false && state.indentType == 0)
				white_lines++;
			if (state.hasChars == false && state.indentType != 0)
				indented_lines++;

			if (state.weakCommentMode)
				state.weakCommentMode = state.commentMode = false;

			state.lineNumber++;
			state.indentNumber = 0;
			state.indentType = 0;
			state.hasChars = false;
			state.stringMode = false;


		// Comments
		} else if (current == '/' && next == '*'
				&& !state.commentMode
				&& !state.stringMode) {
			state.commentMode = true;
			state.hasChars = true;

		} else if (current == '/' && next == '/'
				&& !state.commentMode
				&& !state.stringMode) {
			state.commentMode = true;
			state.weakCommentMode = true;
			state.hasChars = true;

		} else if (prev == '*' && current == '/'
				&& state.commentMode
				&& !state.stringMode) {
			state.commentMode = false;
			state.hasChars = true;

		} else if (current == '#'
				&& !state.hasChars
				&& !state.commentMode
				&& !state.stringMode) {
			state.commentMode = true;
			state.weakCommentMode = true;
			state.hasChars = true;


		// brackets
		} else if (current == '{' && !state.stringMode
				&& !state.commentMode
				&& (prev != '\'' || next != '\'')) {
			if (state.hasChars)
				par_endline++;
			else
				par_begline++;
			state.par_pos.push_back(ib(state.lineNumber, state.hasChars));
			state.hasChars = true;

		} else if (current == '}' && !state.stringMode
				&& !state.commentMode
				&& (prev != '\'' || next != '\'')) {
			if (state.par_pos.size() > 0) {
				ib last = state.par_pos.back();
				state.par_pos.pop_back();
				// count as inline
				if (last.first == state.lineNumber) {
					par_inline++;
					// uncount the previuously counted par
					if (last.second) par_endline--;
					else			 par_begline--;
				}
			} else {
				// this thing can be triggered using the C preprocessor
				// and close the parenthesis many times in conditional
				// blocks
				//fprintf(stderr, "WARNING: unmatched }!\n");
				//fprintf(stderr, "		 File: %s\n", filename);
				//fprintf(stderr, "		 Line: %d\n", state.lineNumber);
			}
			state.hasChars = true;


		// Round pars whit/out spacing
		} else if (current == '('
				&& !state.commentMode
				&& !state.stringMode) {
			if (next == ' ' || next == '\t')
				par_spaced++;
			else
				par_unspaced++;

		} else if (current == ')'
				&& !state.commentMode
				&& !state.stringMode) {
			if (prev == ' ' || prev == '\t')
				par_spaced++;
			else
				par_unspaced++;


		// skip the special chars in the strings (prefixed with \)
		} else if (current == '\\' && state.stringMode && !state.commentMode) {
			state.position++;
			prev = current;
			current = buffer[state.position];
			next = buffer[state.position+1];

		// forced break line [BETA]
		} else if (current == '\\' && next == '\n') {
			state.position++;
			prev = current;
			current = buffer[state.position];
			next = buffer[state.position+1];
			state.lineNumber++;

		// string delimiter
		} else if (current == '"'
				&& !state.commentMode
				&& (prev != '\'' || next != '\'')) {
			// toggle string mode
			state.stringMode = 1 - state.stringMode;
			state.hasChars = true;


		// any other chars
		} else
			state.hasChars = true;


		// go to next char
		state.position++;
	}
}

FileStat::stat_t FileStat::GetStat() {
	stat_t stat;

	stat.par_endline = par_endline;
	stat.par_begline = par_begline;
	stat.par_inline = par_inline;

	stat.ind_tab = ind_tab;
	stat.ind_spa = ind_spa;
	stat.ind_mix = ind_mix;

	stat.white_lines = white_lines;
	stat.indented_lines = indented_lines;

	stat.par_spaced = par_spaced;
	stat.par_unspaced = par_unspaced;

	stat.lines = state.lineNumber;
	stat.file_size = filesize;

	return stat;
}

void FileStat::init() {
	state.position = 0;
	state.lineNumber = 1;
	state.indentNumber = 0;
	state.indentType = 0;
	state.hasChars = false;
	state.stringMode = false;
	state.commentMode = false;
	state.weakCommentMode = false;

	par_endline = 0;
	par_begline = 0;
	par_inline = 0;

	ind_tab = 0;
	ind_spa = 0;
	ind_mix = 0;

	par_spaced = 0;
	par_unspaced = 0;

	white_lines = 0;
	indented_lines = 0;
}
