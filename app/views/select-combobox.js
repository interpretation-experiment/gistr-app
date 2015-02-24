import Ember from 'ember';


export default Ember.Select.extend({
  didInsertElement: function() {
    // Activate the combobox by class selector, to potentially minimize the number of event listeners
    Ember.$(this.get('element')).addClass('combobox');
    Ember.$('.combobox').combobox();
  }
});
