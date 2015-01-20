module.exports = function(app) {
  var env = require('../../config/environment')();
  var express = require('express');
  var sentencesRouter = express.Router();

  sentencesRouter.get('/', function(req, res) {
    res.send({
      "count": 1,
      "next": null,
      "previous": null,
      "results": [
        {
          "author": 1,
          "author_url": "http://127.0.0.1:8000/api/v1/users/1/",
          "author_username": "sl",
          "children": [
            2,
            4
          ],
          "children_urls": [
            "http://127.0.0.1:8000/api/v1/sentences/2/",
            "http://127.0.0.1:8000/api/v1/sentences/4/"
          ],
          "created": "2015-01-15T23:51:22.399373Z",
          "id": 1,
          "parent": null,
          "parent_url": null,
          "text": "Yooooooo",
          "url": "http://127.0.0.1:8000/api/v1/sentences/1/"
        }
      ]
    });
  });

  sentencesRouter.post('/', function(req, res) {
    res.status(201).end();
  });

  sentencesRouter.get('/:id', function(req, res) {
    res.send({
      "author": 1,
      "author_url": "http://127.0.0.1:8000/api/v1/users/1/",
      "author_username": "sl",
      "children": [
        2,
        4
      ],
      "children_urls": [
        "http://127.0.0.1:8000/api/v1/sentences/2/",
        "http://127.0.0.1:8000/api/v1/sentences/4/"
      ],
      "created": "2015-01-15T23:51:22.399373Z",
      "id": 1,
      "parent": null,
      "parent_url": null,
      "text": "Yooooooo",
      "url": "http://127.0.0.1:8000/api/v1/sentences/1/"
    });
  });

  sentencesRouter.put('/:id', function(req, res) {
    res.send({
      "author": 1,
      "author_url": "http://127.0.0.1:8000/api/v1/users/1/",
      "author_username": "sl",
      "children": [
        2,
        4
      ],
      "children_urls": [
        "http://127.0.0.1:8000/api/v1/sentences/2/",
        "http://127.0.0.1:8000/api/v1/sentences/4/"
      ],
      "created": "2015-01-15T23:51:22.399373Z",
      "id": 1,
      "parent": null,
      "parent_url": null,
      "text": "Yooooooo",
      "url": "http://127.0.0.1:8000/api/v1/sentences/1/"
    });
  });

  sentencesRouter.delete('/:id', function(req, res) {
    res.status(204).end();
  });

  app.use('/' + env.APP.API_NAMESPACE + '/sentences', sentencesRouter);
};
