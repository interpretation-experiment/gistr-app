import Ember from 'ember';


export default Ember.Component.extend({
  showIntro: true,

  introSteps: function(user, shaping/*, lifecycle*/) {
    return [
      {
        element: Ember.$('#reading-span-title').get(0),
        intro: "You're about to test your reading-span, welcome!",
        position: "right"
      },
      {
        element: Ember.$('#instruction-read1').get(0),
        intro: `You're going to read a <strong>list of ${shaping.get('readingSpanWordsCount')} words</strong>`,
        position: "right",
        image: 'read1'
      },
      {
        element: Ember.$('#instruction-read2').get(0),
        intro: "In limited time &mdash; <strong>Try to read all the words!</strong>",
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
        intro: "And you must rewrite the words you remember",
        position: "top",
        image: 'write'
      },
      {
        element: Ember.$('#instruction-write').get(0),
        intro: "Capitalization doesn't count, but <strong>typos and spelling changes count as mistakes!</strong>",
        position: "left",
      },
      {
        element: Ember.$('#reading-span-progress').get(0),
        intro: `The whole process loops ${shaping.get('readingSpanTrialsCount')} times, and you're done!`,
        position: "left",
      }
    ];
  },

  actions: {
    showIntro: function() {
      this.set('showIntro', true);
      this.hideAllImages();
    },
    introChange: function(step) {
      this.showImage(step.image);
    },
    introDone: function() {
      this.showAllImages();
      this.set('showIntro', false);
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
    Ember.Object.create({ name: 'read1', title: 'Reading the words', hidden: true }),
    Ember.Object.create({ name: 'read2', title: 'Time is short', hidden: true }),
    Ember.Object.create({ name: 'distract', title: 'Remember it well', hidden: true }),
    Ember.Object.create({ name: 'write', title: 'Writing the words you remember', hidden: true })
  ],
});
