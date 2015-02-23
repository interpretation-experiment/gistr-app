import Ember from 'ember';


function csrfSafeMethod(method) {
  // These HTTP methods do not require CSRF protection
  return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

/*
 * Set up Ajax with proper csrf cookie
 */
export default {
  name: 'csrf',
  initialize: function() {
    Ember.$.ajaxSetup({
      beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
          xhr.setRequestHeader("X-CSRFToken", Ember.$.cookie('csrftoken'));
        }
      }
    });
  }
};
