import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Component.extend(SessionMixin, {
  growl: Ember.inject.service(),

  removing: false,
  isWorking: Ember.computed.or('email.isLoading', 'email.isSaving',
                               'email.isReloading', 'email.isChanging',
                               'removing'),

  actions: {
    verify: function(callback) {
      var growl = this.get('growl'),
          email = this.get('email');
      var promise = request(api(`/emails/${this.get('email.id')}/verify/`), {
        type: 'POST'
      }).then(function() {
        growl.info("Verification email",
                   `A verification email has been sent to ` +
                   `<strong>${email.get('email')}</strong>, please ` +
                   `follow the instructions in it`);
      });
      callback(promise);
    },
    setPrimary: function() {
      this.sendAction('setPrimary', this.get('email'));
    },
    remove: function() {
      this.set('removing', true);
      this.sendAction('remove', this.get('email'));
    }
  }
});
