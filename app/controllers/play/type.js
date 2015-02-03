import Ember from 'ember';

export default Ember.ObjectController.extend({
  text: null,
  errors: null,
  reset: function() {
    this.setProperties({
      text: null,
      errors: null
    });
  },
  actions: {
    // No need to test this
    sendSentence: function() {
      this._sendSentence();
    }
  },
  _sendSentence: function() {
    var self = this;

    this.get('store').createRecord('sentence', {
      text: this.get('text'),
      parent: this.get('model')
    }).save().then(function() {
      self.reset();
      self.transitionToRoute('play.read');
    }, function(error) {
      self.set('errors', error.errors);
    });
  }
});
