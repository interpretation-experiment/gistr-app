import Ember from 'ember';


export default Ember.Service.extend({
  _growl: function(title, text, type) {
    new PNotify({
      title: title,
      text: text,
      opacity: 0.8,
      delay: 5000,
      type: type,
      buttons: { sticker: false },
      animate_speed: 'fast'
    });
  },
  notice: function(title, text) {
    this._growl(title, text, "notice");
  },
  info: function(title, text) {
    this._growl(title, text, "info");
  },
  success: function(title, text) {
    this._growl(title, text, "success");
  },
  error: function(title, text) {
    this._growl(title, text, "error");
  }
});
