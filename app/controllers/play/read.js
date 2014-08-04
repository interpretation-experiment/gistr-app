export default Ember.ObjectController.extend({
  // FIXME: get from params/model
  countdown: 5,

  // FIXME: get from params/model
  updateStep: 0.1,

  // FIXME: untested
  updateCountdown: function() {
    this.set('countdown', this.get('countdown') - this.get('countdownStep'));
  },

  // FIXME: untested
  startCountdown: function(context, callback) {
    this.set('countdownNow', performance.now());
    Ember.run.later(context, callback, this.get('countdown') * 1000);
    Ember.run.later(this, this.updateCurrentCountdown,
                    this.get('updateStep') * 1000);
  },

  // FIXME: untested
  updateCurrentCountdown: function() {
    var now = performance.now(),
        diff = now - this.get('countdownNow');
    this.set('countdownNow', now);
    this.set('countdown', this.get('countdown') - diff / 1000);
    if (this.get('countdown') > 0) {
      Ember.run.later(this, this.updateCurrentCountdown,
                      this.get('updateStep') * 1000);
    }
  }
});
