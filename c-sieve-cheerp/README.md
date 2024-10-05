# Segmented Sieve w/ Cheerp
This project contains experiments running the segmented sieve algorithm on WebAssembly and follows this [tutorial](https://cheerp.io/docs/tutorials/hello-wasm).

Note: This example runs the algorithm for longer than the tutorial mentioned above.

This example shows running the algorithm in three different ways:
1. From a g++ compiled binary
1. From a .js file produced from the cheerp target `cheerp`
1. From a WASM module produced from the cheerp target `cheerp-wasm`

#### Prerequisites
To run these examples you need [cheerp](https://cheerp.io/docs/getting-started/installation) and [NodeJS](https://nodejs.org/en/download/package-manager/current). 

A development shell is provided in the `flake.nix`. This shell builds cheerp from source which can take over 30 minutes.

## Native g++ Binary
Run:
```
g++ segmented_sieve.cpp -o segmented_sieve -O3
./segmented_sieve
```
Result:
```
5.1522e-05s	to sieve in the interval (1, 10)	4 primes found
8.5676e-05s	to sieve in the interval (1, 100)	25 primes found
3.1441e-05s	to sieve in the interval (1, 1000)	168 primes found
4.2575e-05s	to sieve in the interval (1, 10000)	1229 primes found
0.000216738s	to sieve in the interval (1, 100000)	9592 primes found
0.00212573s	to sieve in the interval (1, 1e+06)	78498 primes found
0.0156109s	to sieve in the interval (1, 1e+07)	664579 primes found
0.0439957s	to sieve in the interval (1, 1e+08)	5761455 primes found
0.561395s	to sieve in the interval (1, 1e+09)	50847534 primes found
7.73651s	to sieve in the interval (1, 1e+10)	455052511 primes found
85.5498s	to sieve in the interval (1, 1e+11)	4118054813 primes found
```
## JavaScript
Run:
```
<cheerp clang++> -target cheerp segmented_sieve.cpp -o segmented_sieve_wasm.js -O3
node segmented_sieve.js
```
Result:
```
0.003s	to sieve in the interval (1, 10)	4 primes found
0.002s	to sieve in the interval (1, 100)	25 primes found
0.002s	to sieve in the interval (1, 1000)	168 primes found
0.003s	to sieve in the interval (1, 10000)	1229 primes found
0.01s	to sieve in the interval (1, 100000)	9592 primes found
0.028s	to sieve in the interval (1, 1e+06)	78498 primes found
0.047s	to sieve in the interval (1, 1e+07)	664579 primes found
0.355s	to sieve in the interval (1, 1e+08)	5761455 primes found
3.849s	to sieve in the interval (1, 1e+09)	50847534 primes found
38.242s	to sieve in the interval (1, 1e+10)	455052511 primes found
```
## WebAssembly
Run:
```
<cheerp clang++> -target cheerp-wasm segmented_sieve.cpp -o segmented_sieve_wasm.js -O3
node segmented_sieve_wasm.js
```
Result:
```
0.001s	to sieve in the interval (1, 10)	4 primes found
0s	to sieve in the interval (1, 100)	25 primes found
0s	to sieve in the interval (1, 1000)	168 primes found
0s	to sieve in the interval (1, 10000)	1229 primes found
0s	to sieve in the interval (1, 100000)	9592 primes found
0.001s	to sieve in the interval (1, 1e+06)	78498 primes found
0.008s	to sieve in the interval (1, 1e+07)	664579 primes found
0.093s	to sieve in the interval (1, 1e+08)	5761455 primes found
1.067s	to sieve in the interval (1, 1e+09)	50847534 primes found
12.365s	to sieve in the interval (1, 1e+10)	455052511 primes found
138.381s	to sieve in the interval (1, 1e+11)	4118054813 primes found
```
