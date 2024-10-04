# C - Hello World w/ Emscripten
This example shows building and running a "Hello World" C program as a WASM module using Emscripten.

Much of this is derived from [this](https://emscripten.org/docs/getting_started/Tutorial.html) Emscripten tutorial.

### Prerequisites
In order to run this example you will need [Emscripten](https://emscripten.org/docs/getting_started/downloads.html) and [NodeJS](https://nodejs.org/en/download/package-manager/current). These dependences are provided in the included `shell.nix` or will need to be manually installed.

## Node Module
Here we will build `main.c` into a WASM module and NodeJS module and run them using NodeJS.

1. Compile `main.c` with Emscripten:
```
emcc main.c
```
This creates the WASM module `a.out.wasm` and a Node module `a.out.js`.

2. Run `a.out.js` with node:
```
node a.out.js
```
This will run the WASM module in NodeJS and produce the "Hello, World!" console output.

## HTML In Browser
Emscripten can also generate an HTML file that will load and run the WASM module directly in the browser.

1. Compile `main.c` with Emscripten and tell it to produce an HTML file:
```
emcc hello.c -o hello.html
```
This creates `hello.html`, `hello.js`, and `hello.wasm`. The HTML file loads the JS file which loads and runs the WASM module.

2. To see this in action you must start a webserver and open `hello.html` in a browser.
```
emrun hello.html
```
In a browser, navigate to `/hello.html` on the newly created webserver. You should see the "Hello, World!" message both on screen and in the browsers console (Ctrl+Shift+K on Firefox). You have now just run a C program in the browser!
