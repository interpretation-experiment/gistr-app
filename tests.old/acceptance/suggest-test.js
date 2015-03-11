import Ember from 'ember';
import startApp from '../helpers/start-app';

var App;

module('Acceptances - Suggest', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('suggest renders', function() {
  expect(6);

  visit('/suggest');
  andThen(function() {
    equal(currentRouteName(), 'suggest.new');

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

test('navigate from home to suggest and back', function() {
  expect(2);

  visit('/');
  click('#suggest');
  andThen(function() {
    equal(currentRouteName(), 'suggest.new');
  });

  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
});

test('navigate directly to suggest', function() {
  expect(1);

  visit('/suggest');
  andThen(function() {
    equal(currentRouteName(), 'suggest.new');
  });
});
