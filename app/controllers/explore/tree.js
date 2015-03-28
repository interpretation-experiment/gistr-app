import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {

  /*
   * Selection display and control
   */
  hovered: null,
  selectionStart: null,
  selectionEnd: null,
  selectionPath: null,
  showPath: false,
  reset: function() {
    this.setProperties({
      hovered: null,
      selectionStart: null,
      selectionEnd: null,
      selectionPath: null,
      showPath: false
    });
  },

  hasSelection: Ember.computed.or('selectionStart', 'selectionEnd'),
  hasPath: Ember.computed.gt('selectionPath.length', 0),

  actions: {
    hoverSentence: function(sentence) {
      this.set("hovered", sentence);
    },
    setSelection: function(selection) {
      this.set('showPath', false);
      this.set('selectionStart', selection.start);
      this.set('selectionEnd', selection.end);
      if (!Ember.isNone(selection.path) && selection.path.length > 2) {
        this.set('selectionPath', selection.path.slice(1, -1));
      } else {
        this.set('selectionPath', null);
      }
    },
    togglePath: function() {
      this.set('showPath', !this.get('showPath'));
    },
    reset: function() {
      this.reset();
    }
  }
});
