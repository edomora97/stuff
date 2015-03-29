#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

using namespace std;

int MAX_ITER = 1000;
int WIDTH = 2000;
int HEIGHT = 1000;
const double LEFT = -2;
const double RIGHT = 1;
const double TOP = 1;
const double BOTTOM = -1;

double clamp(double x, double min, double max) {
	if (x < min) return min;
	if (x > max) return max;
	return x;
}

inline double gauss(double w, double x) {
	double a = x/2*w;
	return 1.0/sqrt(w)*exp(-(a*a));
}
inline void wl2rgb(int x, char* colors) {
	double f = 0.01;
	double mult = 255.0/gauss(f, 0);
	*colors++ = clamp(gauss(f, x-660)*mult, 0, 255);
	*colors++ = clamp(gauss(f, x-550)*mult, 0, 255);
	*colors++ = clamp(gauss(f, x-460)*mult, 0, 255);
}

void calcola(double x, double y, char* color) {
	int iter = 0;
	double x0 = x, y0 = y;
	while ((x*x)+(y*y)<4 && iter < MAX_ITER) {
		iter++;
		double nx = x*x-y*y;
		y = 2*x*y + y0;
		x = nx + x0;
	}
	if (iter == MAX_ITER)
		*(color) = *(color+1) = *(color+2) = 0;
	else
		wl2rgb(50*iter%(800-300)+300, color);
}

char* data;

int main(int argc, char** argv) {
	if (argc > 1) {
		WIDTH = atoi(argv[1]);
		HEIGHT = atoi(argv[2]);
	}
	if (argc > 3)
		MAX_ITER = atoi(argv[3]);

	data = new char[WIDTH*HEIGHT*3];

	cout << "P6" << endl;
	cout << WIDTH << " " << HEIGHT << endl << 255 << endl;
	double x = LEFT, y = BOTTOM;
	//#pragma omp parallel for
	for (int i = 0; i < HEIGHT; i++) {
		//#pragma omp atomic
		y += (TOP-BOTTOM)/HEIGHT;
		x = LEFT;
		#pragma omp parallel for schedule(dynamic)
		for (int j = 0; j < WIDTH; j++) {
			#pragma omp atomic
			x += (RIGHT-LEFT)/WIDTH;
			calcola(x, y, data+(i*WIDTH+j)*3);
		}
	}
	for (int i = 0; i < WIDTH*HEIGHT*3; i++)
		putchar_unlocked(data[i]);
}
