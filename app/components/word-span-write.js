import Ember from 'ember';


export default Ember.Component.extend({
  growl: Ember.inject.service(),

  /*
   * Parameters
   */
  wordsCount: null,

  /*
   * Copy-paste prevention
   */
  pasteEvent: 'paste.word-span-write',
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
   * Form meta
   */
  splitter: /, /,
  minTokens: function() {
    var wordsCount = this.get('wordsCount');
    return Math.min(wordsCount - 1, 3);
  }.property('wordsCount'),
  tokens: function() {
    var words = this.get('words') || '';
    if (words.length === 0) { return []; }
    return words.split(this.get('splitter'));
  }.property('words'),
  enoughTokens: function() {
    return this.get('tokens.length') >= this.get('minTokens');
  }.property('tokens.length', 'minTokens'),
  placeholder: function() {
    var wordsCount = this.get('wordsCount');
    return `Type a word and press space (max ${wordsCount} words)`;
  }.property('wordsCount'),
  saveTip: function() {
    var minTokens = this.get('minTokens');
    return `Type at least ${minTokens} words, even if you don't remember them`;
  }.property('minTokens'),

  /*
   * Form fields
   */
  words: null,
  resetInput: function() {
    this.setProperties({
      words: null,
    });
  },

  actions: {
    save: function(callback) {
      var self = this;

      this.set('isSaving', true);
      this.sendAction('save', this.get('tokens'), function() {
        self.set('isSaving', false);
        callback(new Ember.RSVP.Promise(function(r) { r(); }));
      });
    }
  }
});
