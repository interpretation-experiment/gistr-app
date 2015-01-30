import Ember from 'ember';

function csrfSafeMethod(method) {
  // these HTTP methods do not require CSRF protection
  return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

export default {
  name: 'csrf',
  initialize: function() {
    console.log('setup csrf');
    Ember.$.ajaxSetup({
      beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
          xhr.setRequestHeader("X-CSRFToken", Ember.$.cookie('csrftoken'));
        }
      }
    });
  }
};
