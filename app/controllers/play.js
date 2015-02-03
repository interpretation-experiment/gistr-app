/*

// --- controllers/play/read.js
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

    this.set('lastNow', Date.now());
    this.set('preciseCountdown', duration);
    this._updateCountdown();
  },

  _updateCountdown: function() {
    var now = Date.now(),
        diff = now - this.get('lastNow'),
        preciseCountdown = this.get('preciseCountdown') - diff / 1000;

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

// --- controllers/play/type.js
import Ember from 'ember';

export default Ember.ObjectController.extend({
  text: null,
  errors: null,
  reset: function() {
    this.setProperties({
      text: null,
      errors: null
    });
  },
  actions: {
    // No need to test this
    sendSentence: function() {
      this._sendSentence();
    }
  },
  _sendSentence: function() {
    var self = this;

    this.get('store').createRecord('sentence', {
      text: this.get('text'),
      parent: this.get('model')
    }).save().then(function() {
      self.reset();
      self.transitionToRoute('play.read');
    }, function(error) {
      self.set('errors', error.errors);
    });
  }
});

*/
