import Ember from 'ember';


export default Ember.Mixin.create({
  info: Ember.inject.service(),
  infoChecks: Ember.required(),
  infoRouteName: Ember.required(),
  lifecycle: Ember.required(),
  pushInfo: function(info) {
    this.get('info').pushInfo(this.get('infoRouteName'), info);
  },
  freezeInfoChecks: function() {
    var self = this,
        checks = this.get('infoChecks'),
        names = Object.keys(checks),
        freezer = {};

    names.map(function(name) {
      freezer[name] = Ember.run.bind(self, checks[name].freeze)();
    });

    return freezer;
  },
  updateInfos: function(freezer) {
    var self = this,
        currentState = this.get('lifecycle.currentState'),
        checks = this.get('infoChecks'),
        names = Object.keys(checks);

    var updates = names.filter(function(name) {
      var state = self.get('info').split(name).state,
          stateOk = state === 'all' || state === currentState;
      return stateOk && Ember.run.bind(self, checks[name].check)(freezer[name]);
    });

    for (var i = 0; i < updates.length; i++) {
      this.pushInfo(updates[i]);
    }

    return this.getInfos();
  },
  getInfos: function() {
    return this.get('info').getInfos(this.get('infoRouteName'));
  },
  infos: function() {
    return this.getInfos();
  }.property().volatile(),
  resetInfos: function() {
    this.get('info').resetInfos(this.get('infoRouteName'));
  }
});
