import Ember from 'ember';
import startApp from '../../helpers/start-app';
import activatePlayTime from '../../helpers/activate-play-time';
import startPlayTime from '../../helpers/start-play-time';

var App;

module('Acceptances - Play/Read', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('play/read renders', function() {
  expect(9);

  var duration = 0.2,
      precision = 10,
      route = App.__container__.lookup('route:play/read'),
      controller = App.__container__.lookup('controller:play/read');

  controller.set('duration', duration);
  controller.set('precision', precision);

  activatePlayTime(App, false);

  visit('/play/read');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aHome = find('a#home');
    var pInstructions = find('p#instructions');
    var bqText = find('blockquote#text');
    var pCountdown = find('p#countdown');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aHome.text(), 'Home');
    equal(aHome.attr('href'), '/');

    equal(pInstructions.text(), 'Read this carefully:');

    equal(bqText.text(), 'Some first sentence');

    equal(pCountdown.text(), 'Time left:  seconds');

    startPlayTime(App);
    Ember.run.later(this, function() {
      equal(pCountdown.text(), 'Time left: 0.1 seconds');
    }, 300);
  });
});

test('navigate from home to play and back', function() {
  expect(2);

  activatePlayTime(App, false);

  visit('/');
  click('#play');
  andThen(function() {
    equal(currentRouteName(), 'play.read');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
});

test("read transitions to ok after X seconds, and countdown has reached 0", function() {
  expect(2);

  var now = 0,
      duration = 0.2,
      precision = 10,
      controller = App.__container__.lookup('controller:play/read');

  controller.set('duration', duration);
  controller.set('precision', precision);

  activatePlayTime(App, false);

  visit('/play/read');
  andThen(function() {
    now = Date.now();
    startPlayTime(App);
    Ember.run.later(this, function() {
      equal(currentRouteName(), 'play.ok');
    }, 300);
  });
  andThen(function() {
    var countdown = controller.get('countdown');
    ok(countdown === 1 / precision || countdown === 0);
  });
});

test("countdown is cancelled if we transition out of play/read", function() {
  expect(2);

  var duration = 0.2,
      precision = 10,
      lastCountdown,
      route = App.__container__.lookup('route:play/read'),
      controller = App.__container__.lookup('controller:play/read'),
      oCancelCountdown = controller.get('_actions')['cancelCountdown'],
      sCancelCountdown = sinon.spy(oCancelCountdown);

  controller.set('duration', duration);
  controller.set('precision', precision);
  controller.reopen({
    actions: {
      cancelCountdown: sCancelCountdown
    }
  });
  controller.addObserver('countdown', function() {
    lastCountdown = controller.get('countdown');
  });

  activatePlayTime(App, false);
  visit('/play/read');
  andThen(function() {
    startPlayTime(App);
    Ember.run.later(this, function() {
      route.transitionTo('/');
    }, duration * 1000 / 4);
  });
  andThen(function() {
    ok(lastCountdown > duration / 2);
    ok(sCancelCountdown.calledOnce);
    controller.removeObserver('countdown');
  });
});
