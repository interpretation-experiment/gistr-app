import Ember from 'ember';

import splitEvent from 'gistr/utils/split-event';


export default Ember.Mixin.create({
  /*
   * Required properties;
   * - events
   * - actionRoute
   */

  /*
   * Provided helpers
   */
  hasEvents: Ember.computed.notEmpty('events'),
  filterEvents: function(params) {
    var events = this.get('events');

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
  lifecycleEvent: function() {
    var events = this.filterEvents({ type: 'lifecycle' });
    if (events.length > 1) {
      throw new Error("Got more than one lifecycle event: " + events);
    }
    return events.objectAt(0);
  }.property('events'),
  hasTransitioned: function() {
    var lifecycleEvent = this.get('lifecycleEvent');
    // Note that if this is false, then hasStateWorkLeft will be false
    // i.e. with event but not transitioned => no work left
    return !Ember.isNone(lifecycleEvent) && this.get('lifecycle.currentState') !== splitEvent(lifecycleEvent).state;
  }.property('lifecycle.currentState', 'lifecycleEvent'),
  hasStateWorkLeft: function() {
    return this.get('lifecycle.validator.actionRoutes').contains(this.get('actionRoute'));
  }.property('lifecycle.validator.actionRoutes', 'actionRoute'),
});
