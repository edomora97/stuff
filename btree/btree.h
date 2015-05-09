#pragma once

#include <bits/stdc++.h>
using namespace std;

int N = 2;

class node_t {
public:

	class split_t {
	public: 
		int val;
		node_t *sinistra, *destra;
		
		split_t() {
			val = -42;
			sinistra = destra = NULL;
		}
		split_t(int x) {
			val = x;
			sinistra = destra = NULL;
		}
	};


	node_t* padre;
	int* valori;
	node_t** figli;
	int dim;
	bool foglia;
	
	node_t();
	~node_t();
	
	int Trova(int x);
	int PosToInsert(int x);
	void Inserisci(int x);
	void InserisciPadre(split_t& s);
	
	void Stampa(int d = 0);
	
	void Copia(node_t& oth);
	void Distruttore();
	
	int Size();
};

typedef node_t::split_t split_t;

node_t::node_t() {
	padre = NULL;
	valori = new int[2*N];
	memset(valori, 0, sizeof(int)*N);
	
	figli = new node_t*[2*N+1];
	memset(figli, 0, sizeof(node_t*)*(2*N+1));
	
	dim = 0;
	foglia = true;
}

node_t::~node_t() {
	Distruttore();
}

void node_t::Stampa(int d) {
	for (int i = 0; i < d; i++) cout << "--";
	for (int i = 0; i < dim; i++) cout << "(" << valori[i] << ") ";
	cout << "     | " << this << " > " << padre << endl;
	if (!foglia) for (int i = 0; i < dim+1; i++)
		figli[i]->Stampa(d+2);
}

int node_t::Trova(int x) {
	for (int i = 0; i < dim; i++)
		if (valori[i] == x) return i;
	return -1;
}

int node_t::PosToInsert(int x) {
	for (int i = 0; i < dim; i++) 
		if (valori[i] > x)
			return i;
	return dim;
}

void node_t::Inserisci(int x) {
	// nodo foglia con abbastanza spazio
	if (foglia && dim < 2*N) {
		// inserisci in coda e ordina i valori: non ci sono figli
		valori[dim++] = x;
		sort(valori, valori+dim);
	} else {
		// scorre l'albero fino alla foglia corretta
		node_t* current = this;
		while (current->foglia == false)
			current = current->figli[current->PosToInsert(x)];
		
		//         x        nodo da inserire nella foglia
		//  NULL__/ \__NULL
		split_t s(x);
		// Inserisce il nodo
		current->InserisciPadre(s);
	}
}

split_t* Dividi(node_t& n, split_t& s) {
	int dim = n.dim+1;
	int delta = 0;
	
	split_t *split = new split_t;
	split->sinistra = new node_t;
	split->destra = new node_t;
	node_t* padre = n.padre;
	split->sinistra->padre = padre;
	split->destra->padre = padre;
	
	bool foglie = true;
	// Parte sinistra
	for (int i = 0; i < dim/2; i++) {
		// copio finchè non trovo il posto dove inserire s
		if (n.valori[i] < s.val) {
			split->sinistra->valori[i] = n.valori[i];
			split->sinistra->figli[i] = n.figli[i];
			split->sinistra->dim++;
			if (n.figli[i]) foglie = false;
		} else {
			// inserisco s
			split->sinistra->valori[i] = s.val;
			split->sinistra->figli[i] = s.sinistra;
			// collego la parte destra di s
			split->sinistra->figli[i+1] = s.destra;
			split->sinistra->dim++;
			delta = 1;
			// collego le parti destre dei prossimi nodi
			for (i++; i < dim/2; i++) {
				split->sinistra->valori[i] = n.valori[i-1];
				split->sinistra->figli[i+1] = n.figli[i];
				split->sinistra->dim++;
				if (n.figli[i]) foglie = false;
			}
		}
	}
	// se non ho messo s
	if (delta == 0) split->sinistra->figli[dim/2] = n.figli[dim/2];
	
	split->val = n.valori[dim/2-delta];
	// se il nodo da inserire è in mezzo
	if (delta == 0 && s.val < split->val) {
		split->val = s.val;
		split->sinistra->figli[dim/2] = s.sinistra;
		split->destra->figli[0] = s.destra;
		delta = 1;
	}
	
	//cout << "Inizio destra" << endl;
	for (int i = dim/2+1-delta, count = 0; i < dim; i++) {
		if (i < dim-1 && !(s.val < n.valori[i])) {
			split->destra->valori[count] = n.valori[i];
			split->destra->figli[count] = n.figli[i];
			count++;
			split->destra->dim++;
		} else {
			if (delta == 0) {
				split->destra->valori[count] = s.val;
				split->destra->figli[count] = s.sinistra;
				split->destra->figli[count+1] = s.destra;
				count++;
				split->destra->dim++;
			} else if (split->val != s.val) {
				split->destra->figli[0] = n.figli[i];
			}
			for (i++; i < dim; i++) {
				split->destra->valori[count] = n.valori[i-1];
				split->destra->figli[count+1] = n.figli[i];
				count++;
				split->destra->dim++;
			}
		}
	}
	split->sinistra->foglia = split->destra->foglia = foglie;
	if (!foglie) {
		for (int i = 0; i < split->sinistra->dim+1; i++)
			split->sinistra->figli[i]->padre = split->sinistra;
		for (int i = 0; i < split->destra->dim+1; i++)
			split->destra->figli[i]->padre = split->destra;
	}
	return split;
}

node_t* Trova(node_t* n, int x) {
	if (n == NULL) return NULL;
	if (n->Trova(x) != -1) return n;
	return Trova(n->figli[n->PosToInsert(x)], x);
}

void node_t::InserisciPadre(split_t& s) {
	/*cout << "To insert:" << endl;
	if (s.sinistra) s.sinistra->Stampa();
	cout << s.val << endl;
	if (s.destra) s.destra->Stampa();
	cout << "Into:" << endl;
	Stampa();*/
	
	// se c'è spazio nel nodo, cerco la posizione e sostituisco
	// il figlio con lo split_t
	if (dim < 2*N) {
		//cout << "Caso #1" << endl;
		int i;
		for (i = 0; i < dim; i++)
			if (valori[i] > s.val)
				break;
		// shifto i nodi maggiori di s
		for (int j = dim-1; j >= i; j--) {
			valori[j+1] = valori[j];
			figli[j+2] = figli[j+1];
		}
		
		valori[i] = s.val;
		figli[i] = s.sinistra;
		figli[i+1] = s.destra;
		if (!foglia) figli[i]->padre = figli[i+1]->padre = this;
		dim++;
	// se non c'è spazio ma sono sulla radice
	} else if (padre == NULL) {
		//cout << "Caso #2" << endl;
		
		split_t* res = Dividi(*this, s);		
		
		// crea la nuova radice
		node_t* radice = new node_t;
		radice->Inserisci(res->val);
		radice->foglia = false;
		
		/*res->sinistra->Stampa();
		res->destra->Stampa();*/
		
		Copia(*res->sinistra);
		// aggiorna i collegamenti con il padre
		if (!foglia) for (int i = 0; i < dim+1; i++)
			figli[i]->padre = this;
		// collega i due nuovi nodi alla radice
		radice->figli[0] = this;
		radice->figli[1] = res->destra;
		for (int k = 0; k < 2; k++)
			radice->figli[k]->padre = radice;
		
		delete res;
	// non c'è spazio e non sono sulla radice
	} else {
		//cout << "Caso #3" << endl;
		split_t* res = Dividi(*this, s);
		padre->InserisciPadre(*res);
		Copia(*res->sinistra);
		delete res;
	}
}

void node_t::Copia(node_t& oth) {
	padre = oth.padre;
	dim = oth.dim;
	foglia = oth.foglia;
	for (int i = 0; i < dim; i++) {
		valori[i] = oth.valori[i];
		figli[i] = oth.figli[i];
	}
	figli[dim] = oth.figli[dim];
}

void node_t::Distruttore() {
	delete [] valori;
	if (!foglia) for (int i = 0; i < dim+1; i++)
		delete figli[i];
	delete [] figli;
}

int node_t::Size() {
	int s = dim;
	if (!foglia) for (int i = 0; i < dim+1; i++)
		s += figli[i]->Size();
	return s;
}

