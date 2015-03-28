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
    setSelection: function(sentences) {
      this.set('selectionStart', sentences.objectAt(0));
      this.set('selectionEnd', sentences.objectAt(1));
    }
  }
});
