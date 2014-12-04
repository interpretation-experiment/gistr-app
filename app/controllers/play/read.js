import Ember from 'ember';
import ceiling from '../../utils/ceiling';

export default Ember.ObjectController.extend({
  actions: {
    startCountdown: function(route, callback) {
      this._startCountdown(route, callback);
    },
    cancelCountdown: function() {
      this._cancelCountdown();
    }
  },

  // TODO[after backend]: get from params/model
  duration: 5,   // in seconds

  // TODO[after backend]: get from params/model
  precision: 1,  // updates per second

  _startCountdown: function(route, callback) {
    var duration = this.get('duration');
    this.set('transitionTimer',
             setTimeout(Ember.run.bind(route, callback), duration * 1000));

    this._setCountdown(duration);
    this._reschedule();
  },

  _updateCountdown: function() {
    var now = Date.now(),
        diff = now - this.get('lastNow'),
        countdownPrec = this.get('countdownPrec') - diff / 1000;

    this._setCountdown(countdownPrec);
    this._reschedule();
  },

  _cancelCountdown: function() {
    var transitionTimer = this.get('transitionTimer'),
        renderTimer = this.get('renderTimer');

    if (!!transitionTimer) {
      clearTimeout(transitionTimer);
      this.set('transitionTimer', undefined);
    }

    if (!!renderTimer) {
      clearTimeout(renderTimer);
      this.set('renderTimer', undefined);
    }
  },

  _setCountdown: function(countdownPrec) {
    this.set('countdownPrec', countdownPrec);
    this.set('countdown', ceiling(countdownPrec, this.get('precision')));
  },

  _reschedule: function() {
    if (this.get('countdownPrec') > 0) {
      this.set('lastNow', Date.now());
      this.set('renderTimer',
               setTimeout(Ember.run.bind(this, this._updateCountdown),
                          1000.0 / this.get('precision')));
    }
  }
});
