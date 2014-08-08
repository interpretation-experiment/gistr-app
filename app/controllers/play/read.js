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
  ceilingPrecision: 1,  // n times per second
  renderPrecision: 1,   // n times per second

  // FIXME: untested
  _startCountdown: function(route, callback) {
    var duration = this.get('duration');
    this.set('countdown', duration);
    this.set('lastNow', performance.now());
    this.set('transitionTimer',
             Ember.run.later(route, callback, duration * 1000));
    this.set('renderTimer',
             Ember.run.later(this, this._updateCountdown,
                             1000 / this.get('renderPrecision')));
  },

  // FIXME: untested
  _updateCountdown: function() {
    var now = performance.now(),
        diff = now - this.get('lastNow');
    this.set('lastNow', now);
    this.set('countdown', this.get('countdown') - diff / 1000);
    if (this.get('countdown') > 0) {
      Ember.run.later(this, this._updateCountdown,
                      1000 / this.get('renderPrecision'));
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
