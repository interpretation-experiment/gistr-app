import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';
import CtrlEnterNextMixin from 'gistr/mixins/ctrl-enter-next';


export default Ember.Component.extend(TimefulMixin, CtrlEnterNextMixin, {
  duration: 2,  // seconds
  timeLeft: function() {
    var duration = this.get('duration'),
        pProgress = this.get('progress') / 100;
    return 1 + Math.floor(duration * (1 -pProgress));
  }.property('progress'),
  wait: true,
  colors: ['blue', 'blue', 'green'],

  timerDone: function() {
    this.set('wait', false);
  },
  onCtrlEnter: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      if (!this.get('wait')) {
        this.sendAction('next');
      }
    }
  }
});
