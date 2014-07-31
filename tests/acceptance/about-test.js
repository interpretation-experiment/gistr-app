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

  visit('/about').then(function() {
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