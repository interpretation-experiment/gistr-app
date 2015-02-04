import Ember from 'ember';
import config from '../config/environment';

export default Ember.Controller.extend(Ember.FSM.Stateful, {
  pingPeriod: 5,  // in seconds

  delayedCheck: function() {
    Ember.run.later(this, function() {
      this.sendStateEvent('check');
    }, 1000 * this.get('pingPeriod'));
  },
  ping: function() {
    return Ember.$.ajax({
      url: config.APP.API_HOST + config.APP.API_NAMESPACE + '/',
      type: 'HEAD',
      timeout: this.get('pingPeriod') * 1000 / 3
    });
  },

  fsmStates: {
    initialState: 'unknown',
    unknown: { didEnter: 'delayedCheck' },
    online: { didEnter: 'delayedCheck' },
    offline: { didEnter: 'delayedCheck' }
  },
  fsmEvents: {
    check: {
      transitions: { '$all': 'online' },
      before: 'ping'
    },
    error: {
      transition: { '$all': 'offline' }
    },
    reset: {
      transition: { '$all': '$initial' }
    }
  }

});
