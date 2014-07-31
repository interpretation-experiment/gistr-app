var App;

module('Acceptances - Play', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('play renders', function() {
  expect(3);

  visit('/').then(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');
  });
});
