import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  actions: {
    reset: function() {
      // nothing for now
    },
  }
});
