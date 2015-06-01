import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';
import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(TimefulMixin, EnterNextMixin, {
  growl: Ember.inject.service(),
  shaping: Ember.inject.service(),

  /*
   * Copy-paste prevention
   */
  copyEvent: 'copy.reading-span-read',
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
   * Timing
   */
  duration: function() {
    return this.get('shaping.readFactor') * this.get('shaping.readingSpanWordsCount');
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
