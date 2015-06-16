import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  prolificIdRegex: /^[a-z0-9]+$/,

  /*
   * Form fields
   */
  errors: null,
  prolificId: null,
  reset: function() {
    this.setProperties({
      errors: null,
      prolificId: null,
    });
  },

  /*
   * Form actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    clearProlificId: function() {
      delete localStorage.prolificId;
    },
    saveProlificId: function() {
      var prolificId = this.get('prolificId'),
          regex = this.get('prolificIdRegex');
      if (Ember.isNone(regex.exec(prolificId.toLowerCase()))) {
        this.set('errors',
                 { prolificId: "This is not a correct Prolific Academic ID" });
      } else {
        localStorage.prolificId = prolificId.toLowerCase();
        this.transitionToRoute('register');
      }
    }
  }
});
