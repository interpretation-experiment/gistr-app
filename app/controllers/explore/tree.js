import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  hovered: null,
  hasSelection: Ember.computed.or('selectionStart', 'selectionEnd'),
  selectionStart: null,
  selectionEnd: null,

  actions: {
    hoverSentence: function(sentence) {
      this.set("hovered", sentence);
    },
    setSelection: function(selection) {
      this.set('selectionStart', selection.start);
      this.set('selectionEnd', selection.end);
    }
  }
});
