var users = [{ id: '1', nickname: 'jane', sentences: ['1', '5'] },
             { id: '2', nickname: 'neil', sentences: ['2', '4'] },
             { id: '3', nickname: 'chris', sentences: ['3', '6'] }];

var sentences = [{ id: '1', author: '1', from: null, children: ['2', '3'], text: 'Some first sentence' },
                 { id: '2', author: '2', from: '1', children: [], text: 'Some first phrase' },
                 { id: '3', author: '3', from: '1', children: [], text: 'Some first plot' },
                 { id: '4', author: '2', from: null, children: ['5'], text: 'Well now this is nice' },
                 { id: '5', author: '1', from: '4', children: ['6'], text: 'Well now this is neat' },
                 { id: '6', author: '3', from: '5', children: [], text: 'Will you come to eat' }];

module.exports = function(server) {

  // Create an API namespace, so that the root does not
  // have to be repeated for each end point.
  server.namespace('/api/v1', function() {

    // Fixture for a given user
    server.get('/users/:id', function(req, res) {
      res.send({'user': users[parseInt(req.params.id) - 1]});
    });

    // Fixture for all users
    server.get('/users/', function(req, res) {
      res.send({'users': users});
    });

    // Fixture for a given sentence
    server.get('/sentences/:id', function(req, res) {
      res.send({'sentence': sentences[parseInt(req.params.id) - 1]});
    });

    // Fixture for all sentences
    server.get('/sentences/', function(req, res) {
      res.send({'sentences': sentences});
    });

  });
};
