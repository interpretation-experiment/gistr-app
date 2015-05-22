import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  needs: ['application'],

  /*
   * Tabs
   */
  subRoutes: [
    Ember.Object.create({ name: 'profile.profile', label: 'Profile' }),
    Ember.Object.create({ name: 'profile.settings', label: 'Account settings' })
  ],
  currentRouteName: Ember.computed.alias('controllers.application.currentRouteName'),
  watchSubRoutes: function() {
    var self = this,
        current = this.get('currentRouteName'),
        active;

    for (var route of this.get('subRoutes')) {
      active = route.get('name') === current;
      route.set('active', active);
      if (active) { self.set('activeSubRoute', route); }
    }
  }.observes('currentRouteName'),

  /*
   * Profile actions
   */
  actions: {
    transitionTo: function(route) {
      if (Ember.$('body').width() < 768) {
        // Hide the dropdown menu
        Ember.$('.collapse').collapse('hide');
      }

      this.transitionTo(route.get('name'));
    }
  }
});
