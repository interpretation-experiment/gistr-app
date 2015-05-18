import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),

  manualInstructions: false,
  showInstructions: Ember.computed.or('lifecycle.isInExpTraining', 'manualInstructions'),

  actions: {
    manualInstructions: function() {
      this.set('manualInstructions', true);
    },
    next: function() {
      this.sendAction('next');
    }
  }
});
