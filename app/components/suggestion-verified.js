import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Component.extend(SessionMixin, {
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
