module.exports = function(app) {
  var env = require('../../config/environment')();
  var express = require('express');
  var indexRouter = express.Router();

  indexRouter.get('/', function(req, res) {
    res.status(200).end();
  });

  app.use('/' + env.APP.API_NAMESPACE, indexRouter);
};
