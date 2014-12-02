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

  visit('/settings');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aBack = find('a#back');
    var hTitle = find('h2#title');
    var pNo = find('p#no');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aBack.text(), 'Back');
    equal(aBack.attr('href'), '#/');

    equal(hTitle.text(), 'Settings');

    equal(pNo.text(), 'No settings for the moment.');
  });
});

test('navigate from home to settings and back', function() {
  expect(6);

  visit('/');
  click('#settings');
  andThen(function() {
    equal(currentRouteName(), 'settings');
    equal(currentPath(), 'settings');
    equal(currentURL(), '/settings');
  });

  click('#back');
  andThen(function() {
    equal(currentRouteName(), 'index');
    equal(currentPath(), 'index');
    equal(currentURL(), '/');
  });
});
