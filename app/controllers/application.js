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
    var that = this;

    return Ember.$.ajax({
      // TODO[after backend]: change this url to the backend url
      url: window.location.origin,
      type: 'HEAD'
    }).done(function(data, status, xhr) {
      if (status === 'success')
        that.setOnline();
      else
        that.setOffline();
    }).fail(function(xhr, status, error) {
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
  }

});
