Gistr [![Build Status](https://travis-ci.org/interpretation-experiment/gistr-app.svg?branch=master)](https://travis-ci.org/interpretation-experiment/gistr-app) [![Dependencies Status](https://david-dm.org/interpretation-experiment/gistr-app.svg)](https://david-dm.org/interpretation-experiment/gistr-app)
=====

Gistr is both a "broken telephone" (or "chinese whispers") game and an
experiment in cognitive and social science studying how we make sense and
interpret, and long range effects of that.

It is developed for my PhD on interpretation and cultural evolution.

[Dive into more information](https://github.com/interpretation-experiment/gistr-app/wiki).


Get started
-----------

You need a recent version of node and GNU Make. Then:

```
npm install
node_modules/.bin/elm-github-install
make              # For development, output in build/
make prod         # For production, output in dist/
```

For continuous development:

```
./makewatch       # Will continuously build development version
npm run serve     # Will serve and live-reload on rebuilds
```


Tests
-----


### Elm tests

After running `npm install` and `node_modules/.bin/elm-github-install` in the last section, do:

```
cd tests
../node_modules/.bin/elm-github-install
cd ..
node_modules/.bin/elm-test
```

And everything should be green.


### Selenium (browser) tests

These run in Python 3 (tested with Python 3.5+ only). There are two types of tests: normal, which can run on any WebDriver-enabled browser, and concurrent, which need a bit more setup and currently can only be performed using Chromium/Chrome (the behavior on Firefox changes too much when the browser window loses focus, which happens all the time since we spawn several concurrent windows).

TODO: mark concurrent tests with a pytest mark

TODO: run normal (non-concurrent) tests in Travis

TODO: test concurrent tests in xvfb, for Travis

Environment setup (using fish shell with virtualfish, calling this instance "shell 1"):

```
git submodule update --init  # to check out the spreadr submodule
vf new -p (which python3) gistr
pip install -r spreadr/requirements.txt
pip install -r tests/browser/requirements.txt
```

Now in another shell (call it "shell 2"), serve the gistr app:

```
make clean
make
npm run serve
```

Normal tests (back in shell 1):

```
pytest -k test_about  # it's the only test for now
```

Concurrent tests: we run them in a nested X server so that nothing interferes with window focus. So you need to have Xephyr installed (`extra/xorg-server-xephyr` on Arch). Then, in another shell (call it "shell 3"), run:

```
startx -- (which Xephyr) :1 -screen 1200x700x24
```

A nested X server opens up. **Position it such that your mouse doesn't enter it in the following steps.** It's the only reliable way I've found not to interfere with the focus of the browser windows that will open up.

Back in shell 1 with the `gistr` virtualenv activated, run:

```
env DISPLAY=:1 pytest -k test_concurrent_full_runs
```

Which will run the concurrent tests with browser windows in the nested X server. **Do not** enter that nested X server with your mouse while the tests are running, or they will most likely fail. The values in the `tests/browser/conftest.py` fixtures let you configure the tree shaping and concurrency parameters.

Once all browser windows have closed themselves, you can kill the `startx` command in shell 3. The database resulting from the concurrent tests are dumped in the `tests/browser/sqldumps` folder. Load them into another spreadr instance for exploration.


Product Access
--------------

The following companies have donated access to their products.

<a href="https://www.browserstack.com/" title="BrowserStack Website">
  <img src="https://github.com/interpretation-experiment/gistr-app/blob/master/src/assets/img/browser-stack.png" alt="BrowserStack Logo" width="130px"/>
</a>
