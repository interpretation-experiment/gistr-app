import Ember from 'ember';


export default Ember.Controller.extend({
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
