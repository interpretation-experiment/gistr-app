Contributing
============

Environment
-----------

Clone the repository, cd into it, then:

```sh
mkvirtualenv gistr-app
pip install nodeenv
nodeenv -p              # Install node inside the virtualenv
```

Hacking
-------

Quick documentation for code edits.

* [jshint](http://www.jshint.com/) should run without errors.
* [idiomatic.js](https://github.com/rwldrn/idiomatic.js) is about right, with below exceptions.
* 4-character indent, spaces only (no tabs).
* double-quotes for strings.
* No internal space for parentheses; so `if (foo)`, not `if ( foo )`.
* Use [Underscore](http://underscorejs.org/).
* Use [Vows](http://vowsjs.org/).

