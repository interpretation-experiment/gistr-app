var App;

module('Acceptances - Index', {
  setup: function(){
    App = startApp();
  },
  teardown: function() {
    Ember.run(App, 'destroy');
  }
});

test('index renders', function(){
  expect(10);

  visit('/').then(function(){
    var title = find('h2#title');
    var list = find('ul li');
    var pPick = find('p#pick');
    var inputNickname = find('input[name=nickname]');
    var buttonSeed = find('button[name=seed]');
    var buttonInterpret = find('button[name=interpret]');

    equal(title.text(), 'Gistr');

    equal(list.length, 3);
    equal(list.text(), 'redyellowblue');

    equal(pPick.text(), 'Pick a nickname');

    equal(inputNickname.attr('placeholder'), 'e.g. hoory-horse');
    equal(inputNickname.attr('autofocus'), 'autofocus');

    equal(buttonSeed.text(), 'New seed');
    equal(buttonSeed.attr('type'), 'submit');

    equal(buttonInterpret.text(), 'Interpret');
    equal(buttonInterpret.attr('type'), 'submit');
  });
});
