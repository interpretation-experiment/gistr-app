import Ember from 'ember';

import splitEvent from 'gistr/utils/split-event';


export default Ember.Mixin.create({
  info: Ember.inject.service(),

  infoChecks: Ember.required(),
  lifecycle: Ember.required(),

  infos: [],

  pushInfo: function(info) {
    console.log('push info' + info);

    var infos = this.get('infos');
    if (infos.indexOf(info) === -1) { infos.push(info); }

    console.log('infos is now [' + infos.join(", ") + ']');
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
      var state = splitEvent(name).state,
          stateOk = state === 'all' || state.includes(currentState);
      return stateOk && Ember.run.bind(self, checks[name].check)(freezer[name]);
    });

    for (var i = 0; i < updates.length; i++) {
      this.pushInfo(updates[i]);
    }
  },

  resetInfos: function() {
    console.log('reset infos');
    this.set('infos', []);
  }
});
