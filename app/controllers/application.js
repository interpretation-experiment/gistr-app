import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Controller.extend(Ember.FSM.Stateful, {
  /*
   * Parameters
   */
  pingPeriod: 5,  // in seconds

  /*
   * Online/offline ping functions
   */
  delayedCheck: function() {
    Ember.run.later(this, function() {
      this.sendStateEvent('check');
    }, 1000 * this.get('pingPeriod'));
  },
  ping: function() {
    return Ember.$.ajax({
      url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/',
      type: 'HEAD',
      timeout: this.get('pingPeriod') * 1000 / 3
    });
  },

  /*
   * Online/offline FSM states and events
   */
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
