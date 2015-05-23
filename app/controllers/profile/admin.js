import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  needs: [
    'profile/admin/password',
    'profile/admin/username',
  ],
  actions: {
    reset: function() {
      for (var name of this.get('needs')) {
        this.get(`controllers.${name}`).reset();
      }
    },
  }
});
