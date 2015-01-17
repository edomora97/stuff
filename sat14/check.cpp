#include <iostream>
#include <fstream>
#include <cmath>
using namespace std;

int vett[10000000];

int main() {
	int n;
	int m = 0, step = 0;
	
	cin >> n;
	for (int i = 1; i <= n; i++)
		cin >> vett[i];
		
	for (int k = 1; k <= n; k++) {
		int sum = 0;
		for (int i = k; i <= n; i += k) {
			sum += vett[i];
			if (abs(sum) > m) {
				m = abs(sum);
				step = k;
			}
		}
	}
	cout << "RES: " << m  << " (" << step << ")"<< endl;
	int sum = 0;
	for (int i = step; i < n; i += step) {
		sum += vett[i-1];
		cout << (vett[i-1]==1?'+':'-') << " " << sum << endl;
	}
}
