import Ember from 'ember';

import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(EnterNextMixin, {
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
