import Ember from 'ember';

// TODO: test
export default Ember.TextField.extend({
  didInsertElement: function() {
    this.get('element').focus();
  }
});
