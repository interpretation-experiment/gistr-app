import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),

  doIntro: null,
  manualInstructions: false,
  keepInstructions: false,
  showInstructions: Ember.computed.or('doIntro', 'manualInstructions', 'keepInstructions'),
  dontCatchEnter: Ember.computed.or('doIntro', 'manualInstructions'),

  expIntroSteps: function(user, shaping) {
    return [
      {
        element: Ember.$('#exp-title').get(0),
        intro: "Welcome to Gistr's experiment!",
      },
      {
        element: Ember.$('#instruction-read1').get(0),
        intro: "You're going to read a sentence",
        position: "right",
        image: 'read1'
      },
      {
        element: Ember.$('#instruction-read2').get(0),
        intro: "In limited time &mdash; <strong>It's normal if you don't have the time to read it all!</strong>",
        position: "bottom",
        image: 'read2'
      },
      {
        element: Ember.$('#instruction-distract').get(0),
        intro: "Then there's a pause",
        position: "right",
        image: 'distract'
      },
      {
        element: Ember.$('#instruction-write').get(0),
        intro: "And you must rewrite what you remember",
        position: "left",
        image: 'write'
      },
      {
        element: Ember.$('.instructions-drawing').get(0),
        intro: "The whole process loops once you're done",
      },
      {
        element: Ember.$('#training-subtitle').get(0),
        intro: `Right now you're in training &mdash; the real experiment starts after ${shaping.get('trainingWork')} trials`,
        position: "right"
      },
      {
        element: Ember.$('#nav-back').get(0),
        intro: "Quit whenever you want, just click here",
        position: "right"
      }
    ];
  },
  // TODO: explain available sentences, credit system, and 'next credit in'
  playingIntroSteps: function() {},

  actions: {
    showInstructions: function() {
      if (this.get('lifecycle.isInExp')) {
        this.hideAllImages();
      } else if (this.get('lifecycle.isInPlaying')) {
        this.showAllImages();
      }
      this.set('manualInstructions', true);
    },
    introDone: function() {
      this.showAllImages();
      // Keep showing the instructions
      this.set('keepInstructions', true);
      this.set('manualInstructions', false);
      // Inform upper powers, which will set doIntro to false
      this.sendAction('introComplete');
    },
    introChange: function(step) {
      this.showImage(step.image);
    },
    next: function() {
      this.sendAction('next');
    }
  },

  showImage: function(name) {
    this.get('images').map(function(image) {
      if (image.name === name) { image.set('hidden', false); }
    });
  },
  showAllImages: function() {
    this.get('images').map(function(image) {
      image.set('hidden', false);
    });
  },
  hideAllImages: function() {
    this.get('images').map(function(image) {
      image.set('hidden', true);
    });
  },

  images: [
    Ember.Object.create({ name: 'read1', title: 'Reading a sentence', hidden: true }),
    Ember.Object.create({ name: 'read2', title: 'Time is short', hidden: true }),
    Ember.Object.create({ name: 'distract', title: 'Remember it well', hidden: true }),
    Ember.Object.create({ name: 'write', title: 'Writing the sentence', hidden: true })
  ],
});
