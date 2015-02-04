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
    uploadSentence: function() {
      this._uploadSentence();
    }
  },
  _uploadSentence: function() {
    var self = this;

    this.get('store').createRecord('sentence', {
      text: this.get('text')
    }).save().then(function() {
      self.reset();
      self.transitionToRoute('index');
    }, function(error) {
      self.set('errors', error.errors);
    });
  }
});
