import Ember from 'ember';

import ProlificMixin from 'gistr/mixins/prolific';


export default Ember.Controller.extend(ProlificMixin, {
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
