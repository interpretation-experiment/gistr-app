import Ember from 'ember';
import startApp from '../helpers/start-app';

var App;

module('Acceptances - Index', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('index renders', function() {
  expect(14);

  visit('/');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var hTitle = find('h2#title');
    var aPlay = find('a#play');
    var aSuggest = find('a#suggest');
    var aLike = find('a#like');
    var aAbout = find('a#about');
    var aSettings = find('a#settings');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(hTitle.text(), 'Gistr');

    equal(aPlay.text(), 'Play');
    equal(aPlay.attr('href'), '/play/read');

    equal(aSuggest.text(), 'Suggest sentence');
    equal(aSuggest.attr('href'), '/suggest');

    equal(aLike.text(), 'Like');
    equal(aLike.attr('href'), '#');

    equal(aAbout.text(), 'About');
    equal(aAbout.attr('href'), '/about');

    equal(aSettings.text(), 'Settings');
    equal(aSettings.attr('href'), '/settings');
  });
});
