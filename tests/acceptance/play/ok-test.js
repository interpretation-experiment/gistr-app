import Ember from 'ember';
import startApp from '../../helpers/start-app';
import activatePlayTime from '../../helpers/activate-play-time';

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

  activatePlayTime(App, false);

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
  expect(2);

  activatePlayTime(App, false);

  visit('/play/read');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.ok');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
});

test('coming from elsewhere than /play/read redirects [from /]', function() {
  expect(1);

  activatePlayTime(App, false);

  visit('/');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
  });
});

test('coming from elsewhere than /play/read redirects [from /play/type]', function() {
  expect(1);

  activatePlayTime(App, false);

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  visit('/play/ok');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
  });
});

test('coming from elsewhere than /play/read redirects [from /play/ok then /play/type then back]',
     function() {
  expect(2);

  activatePlayTime(App, false);

  visit('/play/read');
  visit('/play/ok');
  visit('/play/type');
  andThen(function() {
    equal(currentRouteName(), 'play.type');
  });
  andThen(function() {
    // This should be window.history.back();
    // But, dong so needs the router to use HashLocation for testing in browser,
    // which in turn makes the test server hang for an unknown reason.
    // So falling back to this for now.
    visit('/play/ok');
  });
  andThen(function() {
    equal(currentRouteName(), 'play.read');
  });
});

test('coming from elsewhere than /play/read redirects [from /play/ok then home then back]',
     function() {
  expect(2);

  activatePlayTime(App, false);

  visit('/play/read');
  visit('/play/ok');
  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
  andThen(function() {
    // This should be window.history.back();
    // But, dong so needs the router to use HashLocation for testing in browser,
    // which in turn makes the test server hang for an unknown reason.
    // So falling back to this for now.
    visit('/play/ok');
  });
  andThen(function() {
    equal(currentRouteName(), 'play.read');
  });
});
