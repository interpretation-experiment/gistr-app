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
  expect(16);

  visit('/').then(function() {
    var pNetstatus = find('p#netstatus');
    var sNetstatus = pNetstatus.find('span');
    var hTitle = find('h2#title');
    var pSentences = find('p#sentences');
    var lSentences = find('ul li');
    var lNickname = find('label[for=nickname]');
    var iNickname = find('input[name=nickname]');
    var bSeed = find('button[name=seed]');
    var bInterpret = find('button[name=interpret]');

    equal(pNetstatus.text(), 'Network status: ' + sNetstatus.text());

    equal(sNetstatus.text(), 'checking');
    equal(sNetstatus.attr('class'), 'checking');

    equal(hTitle.text(), 'Gistr');

    equal(pSentences.text(), 'Sentences being turned on their head right now:');

    equal(lSentences.length, 3);
    equal(lSentences.text(), 'redyellowblue');

    equal(lNickname.text(), 'Pick a nickname');

    equal(iNickname.attr('id'), 'nickname');
    equal(iNickname.attr('type'), 'text');
    equal(iNickname.attr('placeholder'), 'e.g. hoory-horse');
    equal(iNickname.attr('autofocus'), 'autofocus');

    equal(bSeed.text(), 'New seed');
    equal(bSeed.attr('type'), 'submit');

    equal(bInterpret.text(), 'Interpret');
    equal(bInterpret.attr('type'), 'submit');
  });
});
