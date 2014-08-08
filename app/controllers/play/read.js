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
    this.set('countdown', duration);
    this.set('lastNow', performance.now());

    this.set('transitionTimer',
             Ember.run.later(route, callback, duration * 1000));
    this.set('renderTimer',
             Ember.run.later(this, this._updateCountdown,
                             1000 / this.get('precision')));
  },

  // FIXME: untested
  _updateCountdown: function() {
    var now = performance.now(),
        diff = now - this.get('lastNow'),
        precision = this.get('precision'),
        countdown = ceiling(this.get('countdown') - diff / 1000, precision);

    this.set('lastNow', now);
    this.set('countdown', countdown);

    if (countdown > 0) {
      Ember.run.later(this, this._updateCountdown,
                      1000 / this.get('precision'));
    }
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
  }
});
