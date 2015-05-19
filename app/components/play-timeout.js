import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  lifecycle: Ember.inject.service(),
  onEnter: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
