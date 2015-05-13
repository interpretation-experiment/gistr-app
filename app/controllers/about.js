import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  actions: {
    passExperiment: function() {
      if (this.get('session.isAuthenticated')) {
        this.transitionToRoute('play');
      } else {
        this.transitionToRoute('register');
      }
    }
  }
});
