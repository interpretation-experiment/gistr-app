import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
