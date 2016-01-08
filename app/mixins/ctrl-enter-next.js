import Ember from 'ember';


export default Ember.Mixin.create({
  keyupEvent: 'keyup.ctrl-enter-next',
  initKeyListener: function() {
    var self = this;
    Ember.$(window).on(this.get('keyupEvent'), function(event) {
      // Enter key
      if (event.keyCode === 13 && event.ctrlKey && !self.get('dontCatchCtrlEnter')) {
        self.onCtrlEnter();
        // Prevent anything else from happening
        return false;
      }
    });
  }.on('didInsertElement'),
  closeKeyListener: function() {
    Ember.$(window).off(this.get('keyupEvent'));
  }.on('willDestroyElement'),
});
