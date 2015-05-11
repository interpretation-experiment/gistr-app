import Ember from 'ember';

import splitEvent from 'gistr/utils/split-event';


export default Ember.Component.extend({
  infos: null,

  filterInfos: function(params) {
    var self = this,
        infos = this.get('infos');

    var optIncludes = function(part, param) {
      return part.includes(param) || Ember.isNone(param);
    };

    return infos.filter(function(info) {
      var parts = splitEvent(info);
      return (optIncludes(parts.state, params.state) &&
              optIncludes(parts.type, params.type) &&
              optIncludes(parts.name, params.name));
    });
  },

  lifecycleInfos: function() {
    return this.filterInfos({ type: 'lifecycle' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  stateInfos: function() {
    return this.filterInfos({ type: 'state' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  rhythmInfos: function() {
    return this.filterInfos({ type: 'rhythm' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  gainInfos: function() {
    return this.filterInfos({ type: 'gain' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  //infoDetails: {
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
  // - show related info
  // - transition lifecycle if possible
});
