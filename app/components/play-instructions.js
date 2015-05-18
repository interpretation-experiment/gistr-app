import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),

  doIntro: null,
  manualInstructions: false,
  showInstructions: Ember.computed.or('doIntro', 'manualInstructions'),
  dontCatchEnter: Ember.computed.alias('doIntro'),

  expIntroSteps: function() {
    return [
      {
        element: Ember.$('.page-title').get(0),
        intro: 'Welcome to the Experiment page!',
      },
      {
        element: Ember.$('.instructions').get(0),
        intro: "You're going to read a sentence",
      },
      // TODO: mention
      // - limited time, normal if you have no time
      // - distraction task
      // - limited time to write
      // - repeats
      {
        element: Ember.$('#nav-back').get(0),
        intro: "Quit whenever you want, just click here",
        position: "right"
      }
    ];
  },
  // TODO: explain available sentences and 'next credit in'
  playingIntroSteps: function() {},

  actions: {
    showInstructions: function() {
      this.set('manualInstructions', true);
    },
    introComplete: function() {
      // Keep showing the instructions
      this.set('manualInstructions', true);
      // Inform upper powers
      this.sendAction('introComplete');
    },
    next: function() {
      this.sendAction('next');
    }
  }
});
