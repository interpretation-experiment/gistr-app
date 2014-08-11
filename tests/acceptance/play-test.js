var App,
    testDuration = 0.5;

module('Acceptances - Play', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('play renders', function() {
  expect(8);

  // Shorten countdown of play.read, and cancel transition to play.ok
  var prController = App.__container__.lookup('controller:play/read');
  prController.set('duration', testDuration);
  prController.addObserver('transitionTimer', function() {
    Ember.run.cancel(prController.get('transitionTimer'));
  });

  visit('/play');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');

    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aHome = find('a#home');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aHome.text(), 'Home');
    equal(aHome.attr('href'), '/');
  });
});

test('navigate from home to play and back', function() {
  expect(6);

  // Shorten countdown of play.read, and cancel transition to play.ok
  var prController = App.__container__.lookup('controller:play/read');
  prController.set('duration', testDuration);
  prController.addObserver('transitionTimer', function() {
    Ember.run.cancel(prController.get('transitionTimer'));
  });

  visit('/');
  click('#play');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
    equal(currentPath(), 'index');
    equal(currentURL(), '/');
  });
});

test('navigate directly to play', function() {
  expect(3);

  // FIXME: add a test for when the user manually sets the location to /play, after a first load
  // (the visit method doesn't cover this.)

  // Shorten countdown of play.read, and cancel transition to play.ok
  var prController = App.__container__.lookup('controller:play/read');
  prController.set('duration', testDuration);
  prController.addObserver('transitionTimer', function() {
    Ember.run.cancel(prController.get('transitionTimer'));
  });

  visit('/play');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });
});
