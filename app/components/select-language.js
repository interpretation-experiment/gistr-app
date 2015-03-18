import Ember from 'ember';


export default Ember.Component.extend({
  lang: Ember.inject.service(),

  userLanguage: null,
  guess: null,
  isSettingGuess: false,
  isManual: false,

  watchGuess: function() {
    if (!this.get('isManual')) {
      this.set('isSettingGuess', true);
      this.set('language', this.get('guess'));
      this.set('isSettingGuess', false);
    }
  }.observes('guess'),
  setManual: function() {
    if(!this.get('isSettingGuess')) {
      this.set('isManual', true);
    }
  }.observes('language'),

  inform: function() {
    this.sendAction('languageSelected', this.get('language'));
  }.observes('language')
});
