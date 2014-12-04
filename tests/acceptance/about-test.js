import Ember from 'ember';
import startApp from '../helpers/start-app';

var App;

module('Acceptances - About', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('about renders', function() {
  expect(8);

  visit('/about');
  andThen(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var aBack = find('a#back');
    var hTitle = find('h2#title');
    var pDescription = find('p#description');
    var pCredits = find('p#credits');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(aBack.text(), 'Back');
    equal(aBack.attr('href'), '/');

    equal(hTitle.text(), 'About Gistr');

    equal(pDescription.text(), 'Description and rationale.');
    equal(pCredits.text(), 'Credits.');
  });
});

test('navigate from home to about and back', function() {
  expect(6);

  visit('/');
  click('#about');
  andThen(function() {
    equal(currentRouteName(), 'about');
  });

  click('#back');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
});
