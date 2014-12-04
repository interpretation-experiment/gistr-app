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
    var duration = this.get('duration'),
        precision = this.get('precision');

    this.set('transitionTimer',
             setTimeout(Ember.run.bind(route, callback), duration * 1000));
    this.set('renderInterval',
             setInterval(Ember.run.bind(this, this._updateCountdown),
                         1 + 1000.0 / precision));

    this._updateCountdown();
  },

  _updateCountdown: function() {
    var now = Date.now(),
        diff = now - this.getWithDefault('lastNow', now),
        preciseCountdown = this.getWithDefault('preciseCountdown',
                                               this.get('duration')) -
                           diff / 1000;

    this.set('lastNow', now);
    this.set('preciseCountdown', preciseCountdown);
    this.set('countdown', ceiling(preciseCountdown, this.get('precision')));
  },

  _cancelCountdown: function() {
    var transitionTimer = this.get('transitionTimer'),
        renderInterval = this.get('renderInterval');

    if (!!transitionTimer) {
      clearTimeout(transitionTimer);
      this.set('transitionTimer', undefined);
    }

    if (!!renderInterval) {
      clearInterval(renderInterval);
      this.set('renderInterval', undefined);
    }
  }
});
