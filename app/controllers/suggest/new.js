import Ember from 'ember';

export default Ember.ObjectController.extend({
  text: null,
  reset: function() {
    this.setProperties({
      text: null
    });
  },
  actions: {
    // No need to test this
    sendSentence: function() {
      this._sendSentence();
    }
  },
  _sendSentence: function() {
    this.get('store').createRecord('sentence', {
      text: this.get('text')
    }).save();
    this.reset();
    this.transitionToRoute('index');
  }
});
