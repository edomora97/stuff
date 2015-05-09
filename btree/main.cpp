#include <bits/stdc++.h>
#include "btree.h"

using namespace std;

int main(int argc, char** argv) {
	int n;
	if (argc < 2) {
		n = 100000;
		cerr << "WARNING: n = 100000" << endl;
	} else
		n = atoi(argv[1]);
	if (argc < 3) {
		N = 2;
	} else {
		N = atoi(argv[2]);
	}
	
	node_t* btree = new node_t;
	
	int v[n];
	for (int i = 0; i < n; i++) v[i] = i;
	random_shuffle(v, v+n);
	
	clock_t start = clock();
	for (int i = 0; i < n; i++) {
		btree->Inserisci(v[i]);
		// dato che l'albero cresce verso l'alto è necessario spostare
		// la radice
		while (btree->padre) btree = btree->padre;
	}
	cout << (clock()-start)*1000000/CLOCKS_PER_SEC << endl;
	// controlla che tutti i numeri siano presenti nell'albero
	for (int i = 0; i < n; i++)
		assert(Trova(btree, v[i]) != NULL);
}
