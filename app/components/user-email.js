import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Component.extend(SessionMixin, {
  removing: false,
  isWorking: Ember.computed.or('email.isLoading', 'email.isSaving',
                               'email.isReloading', 'email.isChanging',
                               'removing'),

  actions: {
    verify: function(callback) {
      //callback(this.requestVerification());
      console.log('requests verification email, sets justSaved');
      callback('ok');
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
