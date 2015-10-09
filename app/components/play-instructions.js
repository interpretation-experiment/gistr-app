import Ember from 'ember';

import CtrlEnterNextMixin from 'gistr/mixins/ctrl-enter-next';


export default Ember.Component.extend(CtrlEnterNextMixin, {
  lifecycle: Ember.inject.service(),
  assetMap: Ember.inject.service(),

  doExpIntro: null,
  doPlayIntro: null,
  manualIntro: false,
  showIntro: Ember.computed.or('doExpIntro', 'doPlayIntro', 'manualIntro'),
  dontCatchCtrlEnter: Ember.computed.or('doExpIntro', 'doPlayIntro', 'manualIntro'),

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
        intro: "In limited time &mdash; <strong>Try to read as fast as possible!</strong>",
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
        position: "top",
        image: 'write'
      },
      {
        element: Ember.$('#instruction-write').get(0),
        intro: 'Pay attention to <strong>capitalization</strong> and <strong>punctuation</strong>, even at the end of the sentence! (You can ignore ending periods though)',
        position: "left",
      },
      {
        element: Ember.$('.instructions').get(0),
        intro: "The whole process loops once you're done",
      }
    ];
    if (lifecycle.get('isInExpTraining')) {
      steps.push({
        element: Ember.$('#exp-play-title').get(0),
        intro: "Right now you're in <strong>training</strong>: nothing you do is recorded",
        position: "right"
      });
      steps.push({
        element: Ember.$('#exp-progress').get(0),
        intro: `The real experiment starts after ${shaping.get('trainingWork')} trials`,
        position: "left"
      });
    }

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
        element: Ember.$('.instructions').get(0),
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

  initIntro: function() {
    if (this.get('showIntro')) {
      if (this.get('lifecycle.isInExp')) {
        this.hideAllImages();
      } else if (this.get('lifecycle.isInPlaying')) {
        // Do nothing
      } else {
        console.warn(`Asked to show intro when in lifecycle state '${this.get('lifecycle.currentState')}'`);
      }
    }
  }.observes('showIntro').on('init'),
  cleanupIntro: function() {
    this.showAllImages();
    this.set('manualIntro', false);
  },

  onCtrlEnter: function() {
    this.send('next');
  },
  actions: {
    showIntro: function() {
      this.set('manualIntro', true);
    },
    expIntroDone: function() {
      this.cleanupIntro();
      // Inform upper powers, which will set doExpIntro to false
      this.sendAction('expIntroDone');
    },
    playIntroDone: function() {
      this.cleanupIntro();
      // Inform upper powers, which will set doPlayIntro to false
      this.sendAction('playIntroDone');
    },
    expIntroChange: function(step) {
      this.showImage(step.image);
    },
    playIntroChange: function() {
      // Do nothing
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

  imageDefinitions: [
    { name: 'read1', title: 'Reading a sentence', fingerprint: '9d25ea8f14b2019efce93285645929ea' },
    { name: 'read2', title: 'Time is short', fingerprint: 'efb67e2355031e784c8d501ee3dfef90' },
    { name: 'distract', title: 'Remember it well', fingerprint: '2a6b1ed9182367f38ddfcbea8422b5e4' },
    { name: 'write', title: 'Writing the sentence', fingerprint: '0f6c3d49b6ca3f4efa7d93ca9cde25ba' }
  ],
  images: function() {
    var assets = this.get('assetMap');
    return this.get('imageDefinitions').map(function(def) {
      return Ember.Object.create({
        name: def.name,
        source: assets.resolve('assets/images/play/' + def.name, def.fingerprint, '.png'),
        title: def.title,
        hidden: false
      });
    });
  }.property()
});
