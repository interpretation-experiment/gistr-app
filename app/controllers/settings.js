import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Profile form fields
   */
  mothertongue: null,
  errors: null,
  attemptedTransition: null,
  reset: function() {
    this.setProperties({
      mothertongue: null,
      errors: null,
      attemptedTransition: null,
    });
  },

  /*
   * Profile completeness
   */
  isProfileIncomplete: function() {
    return this.get('profileErrors.length') > 0;
  }.property('profileErrors.length'),
  profileErrors: function() {
    if (!this.get('currentProfile')) {
      return ['Set your mothertongue'];
    } else {
      return [];
    }
  }.property('currentProfile'),

  /*
   * Profile actions
   */
  actions: {
    reset: function() {
      this.reset();
    }
  }
});
