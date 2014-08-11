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
      prController = App.__container__.lookup('controller:play/read'),
      nCountdownTests = prController.get('duration') * precision + 1;
  expect(11 + 2 * nCountdownTests);

  prController.set('precision', precision);

  // Cancel transition to play.ok
  prController.addObserver('transitionTimer', function() {
    Ember.run.cancel(prController.get('transitionTimer'));
  });

  // Create our test array of countdown values
  var countdownValues = [],
      countdownValuesExpected = [],
      countdownPrediction = prController.get('duration');
  for (var i = 0; i < nCountdownTests; i++) {
    countdownValuesExpected.push(countdownPrediction);
    countdownPrediction -= 1 / precision;
  }

  prController._reschedule = function() {
    // Test for proper rendering
    andThen(function() {
      var pCountdown = find('p#countdown'),
          countdown = prController.get('countdown');

      countdownValues.push(countdown);
      equal(pCountdown.text(), 'Time left: ' + countdown + ' seconds');

      // Are we done?
      if (countdown > 0) {
        // No: reset lastNow and restart the countdown
        prController.set('lastNow', Date.now());
        prController.set('renderTimer',
                         Ember.run.later(prController, prController._updateCountdown,
                                         1000 / prController.get('precision')));
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

// TODO: test it transitions when reaching 0

// TODO: test it transitions after 5 seconds
