import Ember from 'ember';
import { Ability } from 'ember-can';

import SessionMixin from 'gistr/mixins/session';


export default Ability.extend(SessionMixin, {
  hasSuggestionCredit: Ember.computed.gt('currentProfile.suggestionCredit', 0),
  canCreate: Ember.computed.or('currentUser.isStaff', 'hasSuggestionCredit')
});
