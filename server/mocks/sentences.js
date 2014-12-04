module.exports = function(app) {
  var express = require('express');
  var sentencesRouter = express.Router();

  sentencesRouter.get('/', function(req, res) {
    res.send({
      "sentences": []
    });
  });

  sentencesRouter.post('/', function(req, res) {
    res.status(201).end();
  });

  sentencesRouter.get('/:id', function(req, res) {
    res.send({
      "sentence": {
        id: '1',
        author: '1',
        from: null,
        children: ['2', '3'],
        text: 'Some first sentence'
      }
    });
  });

  sentencesRouter.put('/:id', function(req, res) {
    res.send({
      "sentences": {
        "id": req.params.id
      }
    });
  });

  sentencesRouter.delete('/:id', function(req, res) {
    res.status(204).end();
  });

  app.use('/api/v1/sentences', sentencesRouter);
};
