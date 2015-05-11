import Ember from 'ember';

import splitEvent from 'gistr/utils/split-event';


export default Ember.Component.extend({
  events: null,

  filterEvents: function(params) {
    var self = this,
        events = this.get('events');

    var optIncludes = function(part, param) {
      return part.includes(param) || Ember.isNone(param);
    };

    return events.filter(function(event) {
      var parts = splitEvent(event);
      return (optIncludes(parts.state, params.state) &&
              optIncludes(parts.type, params.type) &&
              optIncludes(parts.name, params.name));
    });
  },

  lifecycleEvents: function() {
    return this.filterEvents({ type: 'lifecycle' });
  }.property(),

  rhythmEvents: function() {
    return this.filterEvents({ type: 'rhythm' });
  }.property(),

  gainEvents: function() {
    return this.filterEvents({ type: 'gain' });
  }.property(),

  // EVENTS
  //    lifecycle w/ or w/o transition [always]
  //    gain [always]
  //    rhythm [if no lifecycle]
  // STATE modulates event if there are events, alone otherwise
  //    no work left == lifecycle w/o transition
  //    empty sentences [quiet if no work left]

});
