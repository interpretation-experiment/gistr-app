import Ember from 'ember';

import { Ability } from 'ember-can';

import SessionMixin from 'gistr/mixins/session';


export default Ability.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),
  canRead: Ember.computed.or('lifecycle.isInPlaying', 'currentUser.isStaff')
});
