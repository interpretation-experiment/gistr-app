import Ember from 'ember';

import { Ability } from 'ember-can';

import SessionMixin from 'gistr/mixins/session';


export default Ability.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),

  canRead: function() {
    // Staff can read everything
    if (this.get('currentUser.isStaff')) { return true; }

    var tree = this.get('model'),
        profileTrees = this.get('currentProfile.trees');

    return this.get('lifecycle.currentState') === 'playing' && profileTrees.contains(tree);
  }.property('currentProfile.trees', 'currentProfile.isStaff', 'lifecycle.currentState')
});
