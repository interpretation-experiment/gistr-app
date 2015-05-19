import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),

  doExpIntro: null,
  doPlayIntro: null,
  doAnIntro: Ember.computed.or('doExpIntro', 'doPlayIntro'),
  manualInstructions: false,
  keepInstructions: false,
  showInstructions: Ember.computed.or('doAnIntro', 'manualInstructions', 'keepInstructions'),
  dontCatchEnter: Ember.computed.or('doAnIntro', 'manualInstructions'),

  expIntroSteps: function(user, shaping, lifecycle) {
    var steps = [
      {
        element: Ember.$('#exp-play-title').get(0),
        intro: "Welcome to Gistr's experiment!",
        position: "right"
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
      }
    ];
    if (lifecycle.get('isInExpTraining')) {
      steps.push({
        element: Ember.$('#exp-play-title').get(0),
        intro: `<p>Right now you're in <strong>training</strong>: nothing you do is recorded.</p><p>The real experiment starts after ${shaping.get('trainingWork')} trials.</p>`,
        position: "right"
      });
    }

    steps.push({
      element: Ember.$('#nav-back').get(0),
      intro: "Quit whenever you want, just click here",
      position: "right"
    });

    return steps;
  },
  playIntroSteps: function(user, shaping) {
    var cost = shaping.get('targetBranchCount') * shaping.get('targetBranchDepth');
    return [
      {
        element: Ember.$('#exp-play-title').get(0),
        intro: "You're now in play mode!",
      },
      {
        element: Ember.$('.instructions-drawing').get(0),
        intro: "<p>It's the same principle.</p><p>But now you can explore how other people transformed sentences! (Go to your home page for that)</p>",
      },
      {
        element: Ember.$('#available-sentences').get(0),
        intro: "This tells you the number of sentences you haven't seen yet &mdash; it grows if other people suggest new ones",
      },
      {
        element: Ember.$('#next-credit').get(0),
        intro: `Every ${cost} sentences you win a <strong>suggestion credit</strong> &mdash; head over to your home page to suggest your sentence!`,
      }
    ];
  },

  afterIntroInstructions: function() {
    this.showAllImages();
    // Keep showing the instructions
    this.set('keepInstructions', true);
    this.set('manualInstructions', false);
  },

  onEnter: function() {
    this.send('next');
  },
  actions: {
    showInstructions: function() {
      if (this.get('lifecycle.isInExp')) {
        this.hideAllImages();
      } else if (this.get('lifecycle.isInPlaying')) {
        this.showAllImages();
      } else {
        console.warn(`Asked to show instructions when in lifecycle state '${this.get('lifecycle.currentState')}'`);
      }
      this.set('manualInstructions', true);
    },
    expIntroDone: function() {
      this.afterIntroInstructions();
      // Inform upper powers, which will set doExpIntro to false
      this.sendAction('expIntroDone');
    },
    playIntroDone: function() {
      this.afterIntroInstructions();
      // Inform upper powers, which will set doPlayIntro to false
      this.sendAction('playIntroDone');
    },
    expIntroChange: function(step) {
      this.showImage(step.image);
    },
    playIntroChange: function() {
      this.showAllImages();
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
