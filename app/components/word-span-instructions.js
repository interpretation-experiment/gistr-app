import Ember from 'ember';


export default Ember.Component.extend({
  assetMap: Ember.inject.service(),

  showIntro: true,

  introSteps: function(user, shaping/*, lifecycle*/) {
    var trainingSizes = shaping.get('wordSpanTrainingSetSizes'),
        taskingSizes = shaping.get('wordSpanTaskingSetSizes'),
        minSize = Math.min(Math.min.apply(null, trainingSizes),
                           Math.min.apply(null, taskingSizes)),
        maxSize = Math.max(Math.max.apply(null, trainingSizes),
                           Math.max.apply(null, taskingSizes)),
        trialsPerSize = shaping.get('wordSpanTrialsPerSetSize'),
        trainingCount = trainingSizes.length * trialsPerSize,
        taskingCount = taskingSizes.length * trialsPerSize;

    return [
      {
        element: Ember.$('#word-span-title').get(0),
        intro: "You're about to test your word span, welcome! Please <strong>read carefully the instructions that follow</strong> (click <em>Next</em> to start)",
        position: "right"
      },
      {
        element: Ember.$('#instruction-read').get(0),
        intro: `You're going to <strong>read a list of words</strong>. We start with a list of ${minSize} words, then the lists get gradually longer, up to ${maxSize} words.`,
        position: "right",
        image: 'read'
      },
      {
        element: Ember.$('#instruction-read').get(0),
        intro: "Try to memorize all the words presented!",
        position: "bottom",
      },
      {
        element: Ember.$('#instruction-write').get(0),
        intro: "Then you must rewrite the words <strong>in the same order</strong>",
        position: "left",
        image: 'write'
      },
      {
        element: Ember.$('#instruction-write').get(0),
        intro: "Capitalization doesn't count, but <strong>typos and spelling changes count as mistakes!</strong>",
        position: "top",
      },
      {
        element: Ember.$('#word-span-progress').get(0),
        intro: `Right now you have <strong>${trainingCount} trials to practice</strong>, then there are <strong>${taskingCount} real trials</strong> and you're done!`,
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
  }.on('didInsertElement'),

  imageDefinitions: [
    { name: 'read', title: 'Reading the words', fingerprint: '4d160a5874d08955462ddb78fdae7800' },
    { name: 'write', title: 'Writing the words in the same order', fingerprint: '8ffafa2e7868b6d8dccfd586a8adcd65' }
  ],
  images: function() {
    var assets = this.get('assetMap');
    return this.get('imageDefinitions').map(function(def) {
      return Ember.Object.create({
        name: def.name,
        source: assets.resolve('assets/images/word-span/' + def.name, def.fingerprint, '.png'),
        title: def.title,
        hidden: true
      });
    });
  }.property()
});
