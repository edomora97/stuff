all: compute test

compute: compute.cpp file.cpp file.h
	g++ compute.cpp file.cpp -o compute -O3

test: test.cpp file.cpp file.h
	g++ test.cpp file.cpp -o test -g

clean:
	rm -rf test compute repos

reset:
	rm -f log* data.csv data.xlsx

install:
	sudo apt-get -y install gnumeric dos2unix wget 
