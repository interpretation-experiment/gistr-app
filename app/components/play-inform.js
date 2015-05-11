import Ember from 'ember';


export default Ember.Component.extend({
  info: Ember.inject.service(),

  routeName: null,

  getInfos: function(params) {
    return this.get('info').getInfos(this.get('routeName'), params);
  },

  lifecycleInfos: function() {
    return this.getInfos({ type: 'lifecycle' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  stateInfos: function() {
    return this.getInfos({ type: 'state' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  rhythmInfos: function() {
    return this.getInfos({ type: 'rhythm' });
    // No need to set the property to volatile since infos won't
    // change while this component exists
  }.property(),

  gainInfos: function() {
    return this.getInfos({ type: 'gain' });
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
