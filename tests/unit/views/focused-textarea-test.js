import {test, moduleFor} from 'ember-qunit';
import FocusedTextAreaView from 'gistr-app/views/focused-textarea';

moduleFor('view:focused-textarea', 'Unit - FocusedTextAreaView');

test("it exists", function() {
  expect(1);
  ok(this.subject() instanceof FocusedTextAreaView);
});

test("it focuses the textarea on didInsertElement", function() {
  expect(1);

  var view = this.subject();
  view.set('element', {
    focus: sinon.spy()
  });

  view.didInsertElement();
  ok(view.get('element').focus.calledOnce);
});
