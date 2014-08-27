import cancelPlayTime from 'appkit/tests/helpers/cancel-play-time';

var App;

module('Acceptances - Play/Type', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('play/type renders', function() {
  expect(9);

  cancelPlayTime(App);

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aHome = find('a#home');
    var pInstructions = find('p#instructions');
    var taText = find('textarea[name=text]');
    var bSend = find('button[name=send]');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aHome.text(), 'Home');
    equal(aHome.attr('href'), '/');

    equal(pInstructions.text(), 'Type the sentence as you remember it:');

    equal(taText.attr('autofocus'), 'autofocus');

    equal(bSend.text(), 'Send');
    equal(bSend.attr('type'), 'submit');
  });
});

test('navigate to home', function() {
  expect(6);

  cancelPlayTime(App);

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  andThen(function() {
    equal(currentRouteName(), 'play.type');
    equal(currentPath(), 'play.type');
    equal(currentURL(), '/play/type');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
    equal(currentPath(), 'index');
    equal(currentURL(), '/');
  });
});

test('coming from elsewhere than /play/read redirects', function() {
  expect(15);

  cancelPlayTime(App);

  visit('/');
  visit('/play/type');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  visit('/');
  visit('/play/read');
  visit('/play/type');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  visit('/');
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
  visit('/play/type');
  click('button[name=send]');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });
  andThen(function() {
    window.history.back();
  });
  andThen(function() {
    equal(currentRouteName(), 'play.read');
    equal(currentPath(), 'play.read');
    equal(currentURL(), '/play/read');
  });
});
