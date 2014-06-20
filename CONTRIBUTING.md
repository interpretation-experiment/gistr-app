Contributing
============

Environment
-----------

Clone the repository, cd into it, then:

```sh
# Set up virtual environment
mkvirtualenv gistr-app
pip install nodeenv
nodeenv -p              # Install node inside the virtualenv

# Install global dependencies
npm install -g grunt-cli bower

# Install local dependencies
npm install
```

Hacking
-------

Quick documentation for code edits.

* [jshint](http://www.jshint.com/) should run without errors.
* [idiomatic.js](https://github.com/rwldrn/idiomatic.js) is about right, with below exceptions.
* 2-character indent, spaces only (no tabs).
* single-quotes for strings.
* No internal space for parentheses; so `if (foo)`, not `if ( foo )`.
* Use [Underscore](http://underscorejs.org/).
* Use [Vows](http://vowsjs.org/).

