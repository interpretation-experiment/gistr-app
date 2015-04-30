import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Service.extend(Ember.FSM.Stateful, SessionMixin, {
  initialize: function(profile) {
    // check this.get('currentProfile') here to set proper state

    this.sendStateEvent('initRegistering');
  },
  reset: function() {
    this.sendStateEvent('reset');
  },
  fsmStates: {
    initialState: 'ground',
  },
  fsmEvents: {
    initRegistering: {
      transition: { '$initial': 'registering' }
    },
    register: {
      transition: { ground: 'registering' }
    },
    initExpTraining: {
      transition: { '$initial': 'exp.training' }
    },
    train: {
      transition: { registering: 'exp.training' }
    },
    initExpDoing: {
      transition: { '$initial': 'exp.doing' }
    },
    doexp: {
      transition: { 'exp.training': 'exp.doing' }
    },
    initPlaying: {
      transition: { '$initial': 'playing' }
    },
    play: {
      transition: { 'exp.doing': 'playing' }
    },
    reset: {
      transition: { '$all': '$initial' }
    }
  }
});
