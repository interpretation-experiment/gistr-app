import Ember from 'ember';

export default Ember.TextArea.extend({
  didInsertElement: function() {
    this.get('element').focus();
  }
});
