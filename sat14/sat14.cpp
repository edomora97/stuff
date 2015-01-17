#include <cmath>
#include <iostream>
using namespace std;

const int MAX = 2;
const int LIMIT = 300;

int data[1000000];

bool check(int n) {
	for (int k = 1; k <= n; k++) {
		int sum = 0;
		for (int i = k; i <= n; i += k) {
			sum += data[i];
			if (abs(sum) > MAX)
				return false;
		}
	}
	return true;
}

void foo(int n) {
	if (n > LIMIT) {
		cout << n-1 << endl;
		for (int i = 1; i < n; i++)
			cout << data[i] << " ";
		cout << endl;
		exit(0);
	}
	int state = rand()%2*2-1;
	data[n] = state;
	if (check(n))
		foo(n+1);
	
	data[n] = -state;
	if (check(n))
		foo(n+1);
}

int main() {
	foo(1);
	cout << "Impossible!" << endl;
}
