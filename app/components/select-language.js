import Ember from 'ember';


export default Ember.Component.extend({
  lang: Ember.inject.service(),

  userLanguage: null,
  guess: null,
  isSettingGuess: false,
  isManual: false,

  setGuess: function() {
    this.set('isSettingGuess', true);
    this.set('language', this.get('guess'));
    this.set('isSettingGuess', false);
  },
  watchGuess: function() {
    if (!this.get('isManual')) {
      this.setGuess();
    }
  }.observes('guess'),
  setManual: function() {
    if(!this.get('isSettingGuess')) {
      this.set('isManual', true);
    }
  }.observes('language'),

  inform: function() {
    this.sendAction('languageSelected', this.get('language'));
  }.observes('language'),

  actions: {
    setAutomatic: function() {
      this.set('isManual', false);
      this.setGuess();
    }
  }
});
