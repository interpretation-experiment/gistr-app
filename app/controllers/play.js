import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import draw from 'gistr/utils/draw';
import randint from 'gistr/utils/randint';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  /*
   * Timing parameters
   */
  precision: 10,     // updates per second
  readDuration: 5,   // in seconds
  writeDuration: 30, // in seconds

  /*
   * Global progress and reset
   */
  reset: function() {
    this.resetProgress();
    this.resetTimers();
    this.resetModels();
  },
  count: 0,
  resetProgress: function() {
    this.setProperties({
      'count': 0
    });
  },
  updateCounts: function() {
    this.incrementProperty('count');
    return this.get('currentProfile').reload();
  },

  /*
   * Current tree and sentence state and selection
   */
  currentSentence: null,
  resetModels: function() {
    this.setProperties({
      currentSentence: null
    });
  },
  selectModels: function() {
    // FIXME: load X trees in one go in route's model hook
    var self = this, profile = this.get('currentProfile'),
        untouchedTreesCount = profile.get('untouchedTreesCount');

    return this.store.find('tree', {
      untouched_by_profile: profile.get('id'),
      page_size: 1,
      page: randint(untouchedTreesCount) + 1
    }).then(function(trees) {
      return trees.objectAt(0).get('sentences');
    }).then(function(sentences) {
      self.set('currentSentence', draw(sentences));
    });
  },
  watchUntouchedTreesCount: function() {
    if (this.get('currentProfile.untouchedTreesCount') === 0) {
      this.sendStateEvent('bail');
    }
  }.observes('currentProfile.untouchedTreesCount'),

  /*
   * Input form fields, state, and upload
   */
  errors: null,
  text: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      errors: null,
      text: null,
      isUploading: null
    });
  },
  uploadSentence: function() {
    var self = this;

    this.set('isUploading', true);
    return this.get('store').createRecord('sentence', {
      text: self.get('text'),
      parent: self.get('currentSentence'),
      language: 'english'  // FIXME: language
    }).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
    });
  },
  // FIXME: move to view
  uploadText: function() {
    if (this.get('isUploading') === true) {
      return 'Uploading...';
    } else {
      return 'Continue';
    }
  }.property('isUploading'),

  /*
   * Suggestion control
   */
  canSuggest: function() {
    // Staff can always suggest
    if (this.get('currentUser.isStaff')) {
      return true;
    }

    return this.get('currentProfile.suggestionCredit') > 0;
  }.property('currentProfile.suggestionCredit', 'currentUser.isStaff'),

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
  readProgress: function() {
    var offset = 100 / (this.get('readDuration') * this.get('precision'));
    return offset + 100 * (1 - this.get('readTime') / this.get('readDuration'));
  }.property('readTime'),
  writeProgress: function() {
    var offset = 100 / (this.get('writeDuration') * this.get('precision'));
    return offset + 100 * (1 - this.get('writeTime') / this.get('writeDuration'));
  }.property('writeTime'),

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
    finish: function() {
      this.sendStateEvent('finish');
    },
    reset: function() {
      this.sendStateEvent('reset');
    },
    uploadSentence: function() {
      this.uploadSentence();
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
      willExit: 'finishWriteTime',
      didExit: 'resetInput'
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
    upload: {
      transition: {
        from: 'writing',
        to: 'verified',
        afterEvent: 'updateCounts'
      }
    },
    timeout: {
      transition: { writing: 'timedout' }
    },
    finish: {
      transition: { verified: 'finished' }
    },
    bail: {
      transition: {
        from: ['instructions', 'verified'],
        to: 'empty'
      }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial',
        didEnter: 'reset'
      }
    }
  }
});
