module.exports = function(server) {

  // Create an API namespace, so that the root does not
  // have to be repeated for each end point.
  server.namespace('/api/v1', function() {

    // Fixture for a given sentence
    server.get('/sentences/:id', function(req, res) {
      var sentence = {
        'sentence': {
          id: '1',
          author: '1',
          from: null,
          children: [],
          text: 'Some first sentence'
        },
        'users': [{
          id: '1',
          nickname: 'jane',
          sentences: ['1']
        }]
      };

      res.send(sentence);
    });

  });
};
