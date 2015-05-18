import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';
import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(TimefulMixin, EnterNextMixin, {
  growl: Ember.inject.service(),

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

  timerDone: function() {
    this.sendAction('timeout');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
