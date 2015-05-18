import Ember from 'ember';


export default Ember.Mixin.create({
  keyupEvent: 'keyup',
  initKeyListener: function() {
    var self = this;
    Ember.$(window).on(this.get('keyupEvent'), function(event) {
      // Enter key
      if (event.keyCode === 13) { self.send('next'); }
    });
  }.on('didInsertElement'),
  closeKeyListener: function() {
    Ember.$(window).off(this.get('keyupEvent'));
  }.on('willDestroyElement'),
});
