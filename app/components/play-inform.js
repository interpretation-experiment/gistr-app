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
    // No need to set the property to volatile since events won't
    // change while this component exists
  }.property(),

  rhythmEvents: function() {
    return this.filterEvents({ type: 'rhythm' });
    // No need to set the property to volatile since events won't
    // change while this component exists
  }.property(),

  gainEvents: function() {
    return this.filterEvents({ type: 'gain' });
    // No need to set the property to volatile since events won't
    // change while this component exists
  }.property(),

  //eventDetails: {
    //'exp.training:lifecycle:just-completed-trials': {
      //title: 'Training finished!',
    //}
    //'exp.doing:lifecycle:just-completed-trials',
    //'all:state:sentences-empty',
    //'playing:state:new-credit',
    //'exp.doing:rhythm:break',
    //'playing:rhythm:diff-break',
    //'playing:rhythm:exploration-break'
  //},
  // TODO:
  // - check lifecycle.validateState to see if additional infos
  // - transition lifecycle if possible
});
