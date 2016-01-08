import Ember from 'ember';

import CtrlEnterNextMixin from 'gistr/mixins/ctrl-enter-next';


export default Ember.Component.extend(CtrlEnterNextMixin, {
  lifecycle: Ember.inject.service(),
  onCtrlEnter: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
