import Ember from 'ember';


export default Ember.Component.extend({
  /*
   * Copy-paste prevention
   */
  pasteEvent: 'paste.reading-span-write',
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

  actions: {
    save: function() {
      this.sendAction('save');
    }
  }
});
