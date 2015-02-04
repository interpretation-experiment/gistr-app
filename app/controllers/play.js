import Ember from 'ember';
import draw from 'gistr/utils/draw';
import config from '../config/environment';

export default Ember.Controller.extend(Ember.FSM.Stateful, {
  /*
   * Timing factors
   */
  precision: 1,  // updates per second
  readDuration: 5,   // in seconds
  writeDuration: 30, // in seconds

  /*
   * Global reset
   */
  reset: function() {
    this.resetProgress();
    this.resetTimers();
    this.resetModels();
  },

  /*
   * Current tree and sentence variables
   */
  currentTree: null,
  currentSentence: null,
  resetModels: function() {
    this.setProperties({
      currentTree: null,
      currentSentence: null
    });
  },

  /*
   * Current tree and sentence selection
   */
  selectModels: function() {
    var self = this, tree = draw(this.get('untouchedTrees'));
    this.set('currentTree', tree);
    return tree.get('sentences').then(function(sentences) {
      self.set('currentSentence', draw(sentences));
    });
  },

  /*
   * Input validation variables
   */
  errors: null,
  text: null,
  resetInput: function() {
    this.setProperties({
      errors: null,
      text: null
    });
  },

  /*
   * Input upload
   */
  uploadSentence: function(transition) {
    var self = this;

    //console.log('uploadSentence');
    //this.testTransition(transition);
    return this.get('store').createRecord('sentence', {
      text: self.get('text'),
      parent: self.get('currentSentence')
    }).save().then(function() {
      console.log('save success');
      self.resetInput();
      self.get('currentTree').set('untouched', false);
    }, function(error) {
      console.log('save error');
      //transition.abort();
      //self.testTransition(transition);
      self.set('errors', error.errors);
    });
  },
  checkUpload: function() {
    if (this.get('errors') === null) {
      console.log('there are NO save errors');
      this.sendStateEvent('verify');
    } else {
      console.log('there are save errors');
      this.sendStateEvent('write');
    }
  },

  testTransition: function(transition) {
    console.log('resolutions: ' + JSON.stringify(transition.get('resolutions')));
    console.log('rejections: ' + JSON.stringify(transition.get('rejections')));
    console.log('aborted: ' + JSON.stringify(transition.get('isAborted')));
    console.log('resolving: ' + JSON.stringify(transition.get('isResolving')));
    console.log('resolved: ' + JSON.stringify(transition.get('isResolved')));
    console.log('rejected: ' + JSON.stringify(transition.get('isRejected')));
  },

  /*
   * Global progress variables
   */
  count: 0,
  resetProgress: function() {
    this.setProperties({
      'count': 0
    });
  },

  /*
   * Timing variables
   */
  lastNow: null,
  readTime: null,
  readTimer: null,
  writeTime: null,
  writeTimer: null,
  resetTimers: function() {
    this.setProperties({
      'lastNow': null,
      'readTime': null,
      'readTimer': null,
      'writeTime': null,
      'writeTimer': null,
    });
  },

  /*
   * Timing observers and triggerers
   */
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

  /*
   * Trial progress actions
   */
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

  /*
   * Trial progress FSM states and events
   */
  fsmStates: {
    initialState: 'instructions',
    reading: {
      willEnter: 'selectModels',
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
      transitions: [
        {
          from: 'holding',
          to: 'writing',
          before: 'resetInput'
        },
        { uploaded: 'writing' }
      ]
    },
    upload: {
      transition: {
        writing: 'uploaded',
        didEnter: 'uploadSentence',
        after: 'checkUpload'
      }
    },
    verify: {
      transition: { uploaded: 'verified' }
    },
    timeout: {
      transition: { writing: 'timedout' }
    },
    finish: {
      transition: { verified: 'finished' }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial',
        didEnter: 'reset'
      }
    }
  },

  /*
   * Trial progress state booleans
   */
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
