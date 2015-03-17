import Ember from 'ember';
import { request } from 'ic-ajax';

import api from 'gistr/utils/api';


export default Ember.Object.extend({
  /*
   * Token variable and validation
   */
  token: null,
  tokenChanged: function() {
    localStorage.gistr_spreadr_auth_token = this.get('token');
    this.setupAjax();
  }.observes('token'),
  hasValidToken: function() {
    var token = this.get('token');
    return (!Ember.isEmpty(token) && token != 'null' && token !== 'undefined');
  }.property('token'),

  /*
   * Set up the Ajax calls with a valid token
   */
  setupAjax: function() {
    var self = this, token = this.get('token');

    Ember.$(document).ajaxSend(function(event, xhr/*, settings*/) {
      if (self.get('hasValidToken')) {
        xhr.setRequestHeader("Authorization", "Token " + token);
      }
    });
  },

  /*
   * Fetch a session using the current token
   */
  fetchSession: function() {
    var self = this, store = this.get('store');

    return request(api('/rest-auth/user/')).then(function(shallowUser) {
      return store.find('user', shallowUser.id);
    }).then(function(user) {
      return { currentUser: user };
    }, function(errors) {
      self.set('token', null);
      throw errors.jqXHR.responseJSON || { non_field_errors: errors.errorThrown };
    });
  },

  /*
   * Adapter hooks: open, fetch, close session
   */
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

    return request(api('/rest-auth/logout/'), { type: 'POST' }).finally(function() {
      self.set('token', null);
    });
  }
});
