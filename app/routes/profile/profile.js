import Ember from 'ember';


export default Ember.Route.extend({
  subscribeLifecycle: function() {
    this.get('lifecycle').subscribe('profile', this.controllerFor('profile.profile.index'));
  }.on('activate'),
  unsubscribeLifecycle: function() {
    this.get('lifecycle').unsubscribe('profile');
  }.on('deactivate')
});
