export default Ember.Controller.extend({
  netstatus: 'checking',

  setOnline: function() {
    this.set('netstatus', 'online');
  },

  setOffline: function() {
    this.set('netstatus', 'offline');
  },

  updateNetstatus: function() {
    var self = this;

    return $.ajax({
      // FIXME: change this url to the backend url
      url: window.location.origin,
      type: 'HEAD'
    }).done(function(data, status, xhr) {
      if (status === 'success')
        self.setOnline();
      else
        self.setOffline();
    }).fail(function(xhr, status, error) {
      self.setOffline();
    });
  },

  updateNetstatusLoop: function() {
    var self = this;

    this.updateNetstatus().always(function() {
      Ember.run.later(self, function() {
        this.updateNetstatusLoop();
      }, 3000);
    });
  }

});
