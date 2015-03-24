import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  hovered: null,

  actions: {
    hoverSentence: function(sentence) {
      this.set("hovered", sentence);
    }
  }
});
