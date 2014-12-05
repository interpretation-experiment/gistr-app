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

  var duration = 0.5,
      precision = 4,
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
      equal(pCountdown.text(), 'Time left: 0.25 seconds');
    }, 1000);
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

//test("read transitions to ok after X seconds, and countdown has reached 0", function() {
  //expect(3);

  //var now = 0,
      //duration = 1,
      //precision = 4,
      //controller = App.__container__.lookup('controller:play/read');

  //controller.set('duration', duration);
  //controller.set('precision', precision);

  //activatePlayTime(App, false);

  //visit('/play/read');
  //andThen(function() {
    //now = Date.now();
    //startPlayTime(App);
  //});
  //andThen(function() {
    //equal(currentRouteName(), 'play.ok');

    //var countdown = controller.get('countdown');
    //ok(countdown === 1 / precision || countdown === 0);
    //// Less than 300ms difference, allowing for runtime imprecisions
    //ok(Math.abs(Date.now() - now - duration * 1000) < 300);
  //});
//});

//test("countdown is cancelled if we transition out of play/read", function() {
  //expect(1);

  //var duration = 2,
      //precision = 4,
      //route = App.__container__.lookup('route:play/read'),
      //controller = App.__container__.lookup('controller:play/read');

  //controller.set('duration', duration);
  //controller.set('precision', precision);

  //activatePlayTime(App, false);
  //visit('/play/read');
  //andThen(function() {
    //startPlayTime(App);
    //Ember.run.later(this, function() {
      //route.transitionTo('/');
    //}, duration * 1000 / 4);
  //});
  //return new Ember.RSVP.Promise(function(resolve, reject) {
    //controller.reopen({
      //actions: {
        //cancelCountdown: function() {
          //ok(this.get('countdown') > duration / 2);
          //resolve(true);
        //}
      //}
    //});
  //});
//});

//test('countdown is launched even when doing read > ok > type > send > back button',
    //function() {
  //expect(4);

  //var route = App.__container__.lookup('route:play/read'),
      //controller = App.__container__.lookup('controller:play/read'),
      //timesEntered = 0,
      //lastEnterTime = 0;

  //route._didTransitionWrapped = route._didTransition;
  //route._didTransition = function() {
    //lastEnterTime = Date.now();
    //timesEntered += 1;
    //this._didTransitionWrapped();
  //};

  //activatePlayTime(App, false);

  //visit('/play/read');  // Entered once
  //visit('/play/ok');
  //visit('/play/type');
  //andThen(function() {
    //activatePlayTime(App, true, 2, 4);
  //});
  //andThen(function() {
    //click('button[name=send]');  // Entered twice

    //// After one second, back button is hit
    //Ember.run.later(this, function() {
      //// This should be window.history.back();
      //// But, dong so needs the router to use HashLocation for testing in browser,
      //// which in turn makes the test server hang for an unknown reason.
      //// So falling back to this for now.
      //visit('/play/type');  // Entered three times
    //}, 1000);

    //// So after two seconds, we're still over one second in the countdown
    //Ember.run.later(this, function() {
      //// Since we're over one second (but not too much over that we're above 1.25),
      //// the ceiling function in countdown gives us 1.25
      //equal(controller.get('countdown'), 1.25);
    //}, 2000);
  //});

  //// After all this, we're at ok with the right timing
  //andThen(function() {
    //equal(currentRouteName(), 'play.ok');

    //equal(timesEntered, 3);
    //// Allowing for 300ms difference (since this does NOT include rendering)
    //ok(Math.abs(Date.now() - lastEnterTime - 2000) < 300);
  //});
//});
