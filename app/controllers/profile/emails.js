import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Global state and reset
   */
  justSaved: false,
  watchSaved: function() {
    if (this.get('justSaved')) {
      Ember.run.later(this, function() {
        this.set('justSaved', false);
      }, 2000);
    }
  }.observes('justSaved'),

  actions: {
    reset: function() {
      // do nothing
    },
  }
});
