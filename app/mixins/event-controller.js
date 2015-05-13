import Ember from 'ember';

import splitEvent from 'gistr/utils/split-event';


export default Ember.Mixin.create({
  eventChecks: Ember.required(),

  events: [],

  pushEvent: function(event) {
    console.log('push event' + event);

    var events = this.get('events');
    if (!events.contains(event)) { events.push(event); }

    console.log('events is now [' + events.join(", ") + ']');
  },

  freezeEventChecks: function(cycleValidation) {
    var self = this,
        checks = this.get('eventChecks'),
        names = Object.keys(checks),
        freezer = {};

    names.map(function(name) {
      freezer[name] = Ember.run.bind(self, checks[name].freeze)(cycleValidation);
    });

    return freezer;
  },

  checkEvents: function(freezer, cycleValidation) {
    // Clear first
    this.set('events', []);

    var self = this,
        currentState = this.get('lifecycle.currentState'),
        checks = this.get('eventChecks'),
        names = Object.keys(checks);

    var updates = names.filter(function(name) {
      var state = splitEvent(name).state,
          stateOk = state === 'all' || state.includes(currentState);
      return stateOk && Ember.run.bind(self, checks[name].check)(freezer[name], cycleValidation);
    });

    for (var i = 0; i < updates.length; i++) {
      this.pushEvent(updates[i]);
    }
  }
});
