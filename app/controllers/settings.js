import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  languages: [
    { name: 'english', label: 'English' },
    { name: 'french', label: 'Français' },
    { name: 'german', label: 'Deutsch' },
    { name: 'spanish', label: 'Español' },
    { name: 'italian', label: 'Italiano' },
  ],

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
  mothertongueChanged: function() {
    console.log(this.get('mothertongue'));
  }.observes('mothertongue'),

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
  }.property('currentProfile')
});
