import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  growl: Ember.inject.service(),

  queryParams: ['key'],
  key: null,
  confirming: false,
  confirmed: false,

  confirmEmail: function() {
    var self = this,
        key = this.get('key'),
        user = this.get('currentUser'),
        growl = this.get('growl');

    this.set('confirming', true);
    request(api('/rest-auth/registration/verify-email/'), {
      type: 'POST',
      data: { key: key }
    }).then(function() {
      self.set('confirmed', true);
      self.set('confirming', false);
      growl.success("Email confirmed",
                    "Your email address was successfully confirmed!");
      return user.reload();
    }).then(function() {
      self.transitionToRoute('profile.emails');
    }, function() {
      growl.error("Confirmation failed",
                  "There was a problem. Did you use the " +
                  "<strong>last verification email</strong> " +
                  "you received?");
    }).finally(function() {
      self.set('confirming', false);
    });
  }.observes('key')
});
