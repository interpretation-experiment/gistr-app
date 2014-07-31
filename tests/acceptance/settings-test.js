var App;

module('Acceptances - Settings', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('settings renders', function() {
  expect(7);

  visit('/settings').then(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aBack = find('a#back');
    var hTitle = find('h2#title');
    var pNo = find('p#no');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aBack.text(), 'Back');
    equal(aBack.attr('href'), '/');

    equal(hTitle.text(), 'Settings');

    equal(pNo.text(), 'No settings for the moment.');
  });
});
