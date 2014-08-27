import cancelPlayTime from 'appkit/tests/helpers/cancel-play-time';

var App;

module('Acceptances - Play/Ok', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('play/ok renders', function() {
  expect(7);

  cancelPlayTime(App);

  visit('/play/read');
  visit('/play/ok');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aHome = find('a#home');
    var aOk = find('a#ok');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aHome.text(), 'Home');
    equal(aHome.attr('href'), '/');

    equal(aOk.text(), 'Ok?');
    equal(aOk.attr('href'), '/play/type');
  });
});

test('navigate to home', function() {
  expect(6);

  cancelPlayTime(App);

  visit('/play/read');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.ok');
    equal(currentPath(), 'play.ok');
    equal(currentURL(), '/play/ok');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
    equal(currentPath(), 'index');
    equal(currentURL(), '/');
  });
});

test('coming from elsewhere than /play/read redirects', function() {
  expect(12);

  cancelPlayTime(App);

  visit('/');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  andThen(function() {
    window.history.back();
  });
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  visit('/play/read');
  visit('/play/ok');
  click('#home');
  andThen(function() {
    window.history.back();
  });
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });
});
