import Ember from 'ember';
import startApp from '../../helpers/start-app';

var App;

module('Acceptances - Suggest/New', {
  setup: function() {
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('suggest/new renders', function() {
  expect(8);

  visit('/suggest/new');
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

    equal(pInstructions.text(), 'Type in your new sentence:');

    // This test fails in PhantomJS because of https://github.com/ariya/phantomjs/issues/10427
    //ok($(taText).is(':focus'));

    equal(bSend.text(), 'Send');
    equal(bSend.attr('type'), 'submit');
  });
});

test('navigate to home', function() {
  expect(2);

  visit('/suggest/new');
  andThen(function() {
    equal(currentRouteName(), 'suggest.new');
  });
  click('#home');
  andThen(function() {
    equal(currentRouteName(), 'index');
  });
});
