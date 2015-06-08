import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import TimefulMixin from 'gistr/mixins/timeful';
import countTokens from 'gistr/utils/count-tokens';


export default Ember.Component.extend(TimefulMixin, SessionMixin, {
  growl: Ember.inject.service(),
  lifecycle: Ember.inject.service(),
  shaping: Ember.inject.service(),

  /*
   * Copy-paste prevention
   */
  pasteEvent: 'paste.play-write',
  initPastePrevention: function() {
    var growl = this.get('growl');
    Ember.$(window).on(this.get('pasteEvent'), function(event) {
      event.preventDefault();
      growl.error("No copy-pasting", "Don't copy-paste the text, it won't work!");
    });
  }.on('didInsertElement'),
  closePastePrevention: function() {
    Ember.$(window).off(this.get('pasteEvent'));
  }.on('willDestroyElement'),

  /*
   * Writing time
   */
  parentSentenceTokensCount: function() {
    return countTokens(this.get('parentSentence.text'));
  }.property('parentSentence.text'),
  duration: function() {
    return this.get('shaping.writeFactor') * this.get('parentSentenceTokensCount');
  }.property('shaping.writeFactor', 'parentSentenceTokensCount'),

  /*
   * Input form fields, state, and upload
   */
  streak: 0,
  errors: null,
  text: null,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      streak: 0,
      errors: null,
      text: null,
      isUploading: false
    });
  },
  upload: function() {
    var self = this,
        profile = this.get('currentProfile'),
        promise;

    this.pauseTime();
    this.set('isUploading', true);
    if (this.get('lifecycle.currentState') === 'exp.training') {
      if (this.get('streak') === this.get('shaping.trainingWork') - 1) {
        // This was the last training trial, we're done with training
        profile.set('trainedReformulations', true);
        promise = profile.save();
      } else {
        // Nothing to do, pass on an empty promise
        promise = new Ember.RSVP.Promise(function(resolve) { resolve(); });
      }
    } else {
      // We're in `exp.doing` or `playing`, save the work
      promise = this.get('store').createRecord('sentence', {
        text: self.get('text'),
        parent: self.get('parentSentence'),
        language: self.get('parentSentence.language'),
        bucket: self.get('parentSentence.bucket'),
        time_proportion: self.get('realProgress') / 100,
        time_allotted: self.get('duration'),
      }).save();
    }

    return promise.then(function(sentence) {
      self.resetInput();
      self.sendAction('next', sentence);
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.resumeTime();
      self.set('isUploading', false);
    });
  },

  /*
   * Token counting
   */
  tokensLeft: function() {
    return Math.max(0, this.get('shaping.minTokens') - this.get('tokenCount'));
  }.property('tokenCount'),
  enoughTokens: Ember.computed.lte('tokensLeft', 0),
  tokensCountInfo: function() {
    if (this.get('enoughTokens')) { return; }

    var info = "Your sentence must be at least " + this.get('shaping.minTokens') + " words long";
    if (this.get('text')) {
      info += " (type " + this.get('tokensLeft') + " more)";
    }
    return info;
  }.property('enoughTokens', 'tokensLeft'),

  /*
   * When time is up
   */
  timerDone: function() {
    this.sendAction('timeout');
  },

  /*
   * Form actions and updates from components
   */
  actions: {
    upload: function(callback) {
      callback(this.upload());
    },
    updateMetaText: function(data) {
      this.setProperties({
        tokenCount: data.tokenCount,
      });
    },
    enterPressed: function() {
      if (this.get('enoughTokens')) {
        this.$('#active-submit').click();
      } else {
        var submit = this.$('#inactive-submit');
        submit.mouseenter();
        Ember.run.later(null, function() {
          submit.mouseleave();
        }, 2000);
      }
    }
  }
});
