import Ember from 'ember';


export default Ember.Component.extend(Ember.FSM.Stateful, {
  growl: Ember.inject.service(),
  shaping: Ember.inject.service(),

  /*
   * Copy-paste prevention
   */
  copyEvent: 'copy.word-span-read',
  initCopyPrevention: function() {
    var growl = this.get('growl');
    Ember.$(window).on(this.get('copyEvent'), function(event) {
      event.preventDefault();
      growl.error("No copy-pasting", "Don't copy-paste the text, it won't work!");
    });
  }.on('didInsertElement'),
  closeCopyPrevention: function() {
    Ember.$(window).off(this.get('copyEvent'));
  }.on('willDestroyElement'),

  /*
   * Timing and cycle
   */
  readDuration: 1,     // in seconds
  emptyDuration: 0.5,  // in seconds
  timer: null,
  cycle: 0,
  cycleCount: Ember.computed.alias('words.length'),
  bumpCycle: function() {
    this.incrementProperty('cycle');
  },
  word: function() {
    return this.get('words').get(this.get('cycle'));
  }.property('cycle'),
  cycleEmpty: function() {
    var timer = Ember.run.later(this, function() {
      if (this.get('cycle') === this.get('cycleCount')) {
        this.sendStateEvent('finish');
      } else {
        this.sendStateEvent('read');
      }
    }, this.get('emptyDuration') * 1000);
    this.set('timer', timer);
  }.on('didInsertElement'),
  cycleRead: function() {
    var timer = Ember.run.later(this, function() {
      this.sendStateEvent('empty');
    }, this.get('readDuration') * 1000);
    this.set('timer', timer);
  },
  closeCycle: function() {
    Ember.run.cancel(this.get('timer'));
  }.on('willDestroyElement'),

  fsmStates: {
    initialState: 'empty',
    knownStates: ['empty', 'reading', 'finished', 'failed'],
    empty: {
      enter: 'cycleEmpty'
    },
    reading: {
      enter: 'cycleRead'
    }
  },
  fsmEvents: {
    empty: {
      transition: {
        reading: 'empty',
        enter: 'bumpCycle'
      }
    },
    read: {
      transition: { empty: 'reading' }
    },
    finish: {
      transition: {
        empty: 'finished',
        enter: 'finish'
      }
    }
  },

  /*
   * Cycle actions
   */
  finish: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
