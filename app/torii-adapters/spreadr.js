import Ember from 'ember';
import config from 'gistr/config/environment';

export default Ember.Object.extend({

  token: null,

  hasValidToken: function() {
    var token = this.get('token');
    return (!Ember.isEmpty(token) && token != 'null' && token !== 'undefined');
  }.property('token'),

  setupAjax: function() {
    var self = this, token = this.get('token');

    Ember.$(document).ajaxSend(function(event, xhr/*, settings*/) {
      if (self.get('hasValidToken')) {
        xhr.setRequestHeader("Authorization", "Token " + token);
      }
    });
  },

  tokenChanged: function() {
    localStorage.gistr_spreadr_auth_token = this.get('token');
    this.setupAjax();
  }.observes('token'),

  fetchSession: function() {
    var self = this, store = this.get('store');

    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        dataType: 'json',
        url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/rest-auth/user/',
        success: Ember.run.bind(null, resolve),
        error: Ember.run.bind(null, reject)
      });
    }).then(function(shallowUser) {
      return store.find('user', shallowUser.id);
    }).then(function(user) {
      return { currentUser: user };
    }, function(xhr, error, errorThrown) {
      self.set('token', null);
      throw xhr.responseJSON || { non_field_errors: errorThrown };
    });
  },

  open: function(authorization) {
    this.set('token', authorization.key);
    return this.fetchSession();
  },

  fetch: function() {
    this.set('token', localStorage.gistr_spreadr_auth_token);
    return this.fetchSession();
  },

  close: function() {
    var self = this;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        dataType: 'json',
        url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/rest-auth/logout/',
        success: Ember.run.bind(null, resolve),
        error: Ember.run.bind(null, reject)
      });
    }).then(function() {
      self.set('token', null);
    }, function(xhr, error, errorThrown) {
      throw xhr.responseJSON || { non_field_errors: errorThrown };
    });
  }

});
