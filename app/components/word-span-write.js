import Ember from 'ember';


export default Ember.Component.extend({
  growl: Ember.inject.service(),
  shaping: Ember.inject.service(),

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
  minTokens: 3,
  tokens: function() {
    var words = this.get('words') || '';
    return words.split(this.get('splitter'));
  }.property('words'),
  enoughTokens: Ember.computed.gte('tokens.length', 3),
  placeholder: function() {
    var wordsCount = this.get('shaping.wordSpanWordsCount');
    return `Type a word and press space (max ${wordsCount} words)`;
  }.property(),

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
