import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';


export default Ember.Component.extend(TimefulMixin, {
  timerDone: function() {
    this.sendAction('timeout');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
