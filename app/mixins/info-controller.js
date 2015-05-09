import Ember from 'ember';


export default Ember.Mixin.create({
  info: Ember.inject.service(),
  infoRouteName: Ember.required(),
  pushInfo: function(info) {
    this.get('info').pushInfo(this.get('infoRouteName'), info);
  },
  getInfos: function() {
    return this.get('info').getInfos(this.get('infoRouteName'));
  },
  resetInfos: function() {
    this.get('info').resetInfos(this.get('infoRouteName'));
  }
});
