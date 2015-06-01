import Ember from 'ember';



export default Ember.TextField.extend({
  initTokenField: function() {
    this.$().tokenfield({
      delimiter: [',', ' '],
      createTokensOnBlur: true,
      minLength: this.getWithDefault('minLength', 0),
      limit: this.getWithDefault('limit', 0)
    });
    Ember.$('input.token-input').focus();
  }.on('didInsertElement')
});
