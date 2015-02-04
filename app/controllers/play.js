import Ember from 'ember';

export default Ember.ObjectController.extend(Ember.FSM.Stateful, {
  precision: 1,  // updates per second
  readDuration: 5,   // in seconds
  writeDuration: 5, // in seconds

  count: 0,
  lastNow: null,
  readTime: null,
  readTimer: null,
  writeTime: null,
  writeTimer: null,
  reset: function() {
    this.setProperties({
      'count': 0,
      'lastNow': null,
      'readTime': null,
      'readTimer': null,
      'writeTime': null,
      'writeTimer': null,
    });
  },

  readTimeChanged: function() {
    var readTime = this.get('readTime');
    if (!!readTime && readTime <= 0) {
      this.sendStateEvent('hold');
    }
  }.observes('readTime'),
  updateReadTime: function() {
    var now = Date.now(), diff = now - this.get('lastNow');
    this.setProperties({
      'lastNow': now,
      'readTime': this.get('readTime')  - diff / 1000,
      'readTimer': Ember.run.later(this, this.updateReadTime,
                                   1000 / this.get('precision'))
    });
  },
  startReadTime: function() {
    this.setProperties({
      'lastNow': Date.now(),
      'readTime': this.get('readDuration'),
      'readTimer': Ember.run.later(this, this.updateReadTime,
                                   1000 / this.get('precision'))
    });
  },
  finishReadTime: function() {
    Ember.run.cancel(this.get('readTimer'));
    this.setProperties({
      'readTime': null,
      'readTimer': null
    });
  },

  writeTimeChanged: function() {
    var writeTime = this.get('writeTime');
    if (!!writeTime && writeTime <= 0) {
      this.sendStateEvent('timeout');
    }
  }.observes('writeTime'),
  updateWriteTime: function() {
    var now = Date.now(), diff = now - this.get('lastNow');
    this.setProperties({
      'lastNow': now,
      'writeTime': this.get('writeTime')  - diff / 1000,
      'writeTimer': Ember.run.later(this, this.updateWriteTime,
                                    1000 / this.get('precision'))
    });
  },
  startWriteTime: function() {
    this.setProperties({
      'lastNow': Date.now(),
      'writeTime': this.get('writeDuration'),
      'writeTimer': Ember.run.later(this, this.updateWriteTime,
                                    1000 / this.get('precision'))
    });
  },
  finishWriteTime: function() {
    Ember.run.cancel(this.get('writeTimer'));
    this.setProperties({
      'writeTime': null,
      'writeTimer': null
    });
  },

  actions: {
    read: function() {
      this.sendStateEvent('read');
    },
    hold: function() {
      this.sendStateEvent('hold');
    },
    write: function() {
      this.sendStateEvent('write');
    },
    upload: function() {
      this.sendStateEvent('upload');
    },
    finish: function() {
      this.sendStateEvent('finish');
    },
    reset: function() {
      this.sendStateEvent('reset');
    }
  },

  fsmStates: {
    initialState: 'instructions',
    reading: {
      didEnter: 'startReadTime',
      willExit: 'finishReadTime'
    },
    writing: {
      didEnter: 'startWriteTime',
      willExit: 'finishWriteTime'
    },
    verified: {
      didEnter: function() {
        this.incrementProperty('count');
      }
    }
  },
  fsmEvents: {
    read: {
      transitions: {
        from: ['instructions', 'verified', 'timedout'],
        to: 'reading'
      }
    },
    hold: {
      transition: { reading: 'holding' }
    },
    write: {
      transition: { holding: 'writing' }
    },
    timeout: {
      transition: { writing: 'timedout' }
    },
    upload: {
      transition: { writing: 'verified' }
    },
    finish: {
      transition: { verified: 'finished' }
    },
    reset: {
      transition: {
        from: '$all',
        to: 'instructions',
        didEnter: 'reset'
      }
    }
  },

  stateIsInstructions: function() {
    return this.get('currentState') === 'instructions';
  }.property('currentState'),
  stateIsReading: function() {
    return this.get('currentState') === 'reading';
  }.property('currentState'),
  stateIsHolding: function() {
    return this.get('currentState') === 'holding';
  }.property('currentState'),
  stateIsWriting: function() {
    return this.get('currentState') === 'writing';
  }.property('currentState'),
  stateIsTimedout: function() {
    return this.get('currentState') === 'timedout';
  }.property('currentState'),
  stateIsVerified: function() {
    return this.get('currentState') === 'verified';
  }.property('currentState'),
  stateIsFinished: function() {
    return this.get('currentState') === 'finished';
  }.property('currentState')
});
/*

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
