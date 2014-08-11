import ceiling from 'appkit/utils/ceiling';

export default Ember.ObjectController.extend({
  actions: {
    // FIXME: untested
    startCountdown: function(route, callback) {
      this._startCountdown(route, callback);
    },
    // FIXME: untested
    cancelCountdown: function() {
      this._cancelCountdown();
    }
  },

  // FIXME: get from params/model
  duration: 5,

  // FIXME: get from params/model
  precision: 1,  // n times per second

  // FIXME: untested
  _startCountdown: function(route, callback) {
    var duration = this.get('duration');
    this.set('transitionTimer',
             Ember.run.later(route, callback, duration * 1000));

    this._setCountdown(duration);
    this._reschedule();
  },

  // FIXME: untested
  _updateCountdown: function() {
    var now = Date.now(),
        diff = now - this.get('lastNow'),
        precision = this.get('precision'),
        countdownPrec = this.get('countdownPrec') - diff / 1000;

    this._setCountdown(countdownPrec);
    this._reschedule();
  },

  // FIXME: untested
  _cancelCountdown: function() {
    var transitionTimer = this.get('transitionTimer'),
        renderTimer = this.get('renderTimer');

    if (!!transitionTimer) {
      Ember.run.cancel(transitionTimer);
      this.set('transitionTimer', undefined);
    }

    if (!!renderTimer) {
      Ember.run.cancel(renderTimer);
      this.set('renderTimer', undefined);
    }
  },

  // FIXME: untested
  _setCountdown: function(countdownPrec) {
    this.set('countdownPrec', countdownPrec);
    this.set('countdown', ceiling(countdownPrec, this.get('precision')));
  },

  // FIXME: untested
  _reschedule: function() {
    if (this.get('countdown') > 0) {
      this.set('lastNow', Date.now());
      this.set('renderTimer',
               Ember.run.later(this, this._updateCountdown,
                               1000 / this.get('precision')));
    }
  }
});
