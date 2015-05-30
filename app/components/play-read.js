import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';
import EnterNextMixin from 'gistr/mixins/enter-next';
import countTokens from 'gistr/utils/count-tokens';


export default Ember.Component.extend(TimefulMixin, EnterNextMixin, {
  growl: Ember.inject.service(),
  shaping: Ember.inject.service(),

  /*
   * Copy-paste prevention
   */
  copyEvent: 'copy.play-read',
  initCopyPrevention: function() {
    var growl = this.get('growl');
    Ember.$(window).on(this.get('copyEvent'), function(event) {
      event.preventDefault();
      growl.error("No copy-pasting", "Don't copy-paste the text, it won't work!");
    });
  }.on('didInsertElement'),
  closeCopyPrevention: function() {
    Ember.$(window).off(this.get('copyEvent'));
  }.on('willDestroyElement'),

  /*
   * Reading time
   */
  sentenceTokensCount: function() {
    return countTokens(this.get('sentence.text'));
  }.property('sentence.text'),
  duration: function() {
    return this.get('shaping.readFactor') * this.get('sentenceTokensCount');
  }.property('shaping.readFactor', 'sentenceTokensCount'),

  timerDone: function() {
    this.sendAction('next');
  },
  onEnter: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
