import cancelPlayTime from 'appkit/tests/helpers/cancel-play-time';

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
  var precision = 4,
      controller = App.__container__.lookup('controller:play/read'),
      nCountdownTests = controller.get('duration') * precision + 1;
  expect(11 + 2 * nCountdownTests);

  controller.set('precision', precision);

  // Cancel transition to play.ok
  controller.addObserver('transitionTimer', function() {
    Ember.run.cancel(controller.get('transitionTimer'));
  });

  // Create our test array of countdown values
  var countdownValues = [],
      countdownValuesExpected = [],
      countdownPrediction = controller.get('duration');
  for (var i = 0; i < nCountdownTests; i++) {
    countdownValuesExpected.push(countdownPrediction);
    countdownPrediction -= 1 / precision;
  }

  controller._reschedule = function() {
    // Test for proper rendering
    andThen(function() {
      var pCountdown = find('p#countdown'),
          countdown = controller.get('countdown');

      countdownValues.push(countdown);
      equal(pCountdown.text(), 'Time left: ' + countdown + ' seconds');

      // Are we done?
      if (countdown > 0) {
        // No: reset lastNow and restart the countdown
        controller.set('lastNow', Date.now());
        controller.set('renderTimer',
                       Ember.run.later(controller, controller._updateCountdown,
                                       1000 / controller.get('precision')));
      } else {
        // Yes: test for proper final rendering
        equal(currentRouteName(), 'play.read');
        equal(currentPath(), 'play.read');
        equal(currentURL(), '/play/read');

        var pNetstatus = find('p#netstatus');
        var sNetstatus = pNetstatus.find('span');
        var aHome = find('a#home');
        var pInstructions = find('p#instructions');
        var bqText = find('blockquote#text');
        pCountdown = find('p#countdown');

        equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

        equal(sNetstatus.text(), 'checking');
        equal(sNetstatus.attr('class'), 'checking');

        equal(aHome.text(), 'Home');
        equal(aHome.attr('href'), '/');

        equal(pInstructions.text(), 'Read this carefully:');

        equal(bqText.text(), 'Some first sentence');

        equal(pCountdown.text(), 'Time left: 0 seconds');

        // Check we saw the right time values
        for (var i = 0; i < nCountdownTests; i++) {
          ok(Math.abs(countdownValues[i] - countdownValuesExpected[i]) < 1e-10);
        }
      }
    });
  };

  visit('/play/read');
});

test('navigate from home to play and back', function() {
  expect(6);

  cancelPlayTime(App);

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

test("read transitions to ok after X seconds, and countdown has reached 0", function() {
  expect(5);

  var duration = 1,
      precision = 4,
      controller = App.__container__.lookup('controller:play/read');

  controller.set('duration', duration);
  controller.set('precision', precision);
  var now = Date.now();
  visit('/play/read');
  andThen(function() {
    equal(currentRouteName(), 'play.ok');
    equal(currentPath(), 'play.ok');
    equal(currentURL(), '/play/ok');

    equal(controller.get('countdown'), 0.25);
    // Less than 200ms difference, allowing for runtime imprecisions
    ok(Math.abs(Date.now() - now - duration * 1000) < 200);
  });
});

// TODO: test it cancels the countdown if transitioned out of this route
