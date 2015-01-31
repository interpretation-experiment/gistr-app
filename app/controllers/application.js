import Ember from 'ember';
import config from '../config/environment';

export default Ember.Controller.extend({
  netstatus: 'checking',

  setOnline: function() {
    this.set('netstatus', 'online');
  },

  setOffline: function() {
    this.set('netstatus', 'offline');
  },

  // FIXME[try promises]: untested
  updateNetstatus: function() {
    var that = this,
        pingBack = config.APP.API_HOST + config.APP.API_NAMESPACE + '/';

    return Ember.$.ajax({
      url: pingBack,
      type: 'HEAD'
    }).done(function(/*data, status, xhr*/) {
      that.setOnline();
    }).fail(function(/*xhr, status, error*/) {
      that.setOffline();
    });
  },

  // FIXME[try promises]: untested
  updateNetstatusLoop: function() {
    var that = this;

    this.updateNetstatus().always(function() {
      Ember.run.later(that, function() {
        this.updateNetstatusLoop();
      }, 3000);
    });
  },

  init: function() {
    this._super();
    this.get('session').fetch('spreadr');
  },

  actions: {
    logout: function() {
      this.get('session').close('spreadr');
    }
  }

});
