import Ember from 'ember';

export default Ember.Mixin.create({
  /*
   * Our user
   */
  currentUser: Ember.computed.alias('session.currentUser'),
  currentProfile: Ember.computed.alias('session.currentUser.profile')
});
