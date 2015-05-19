import Ember from 'ember';

import { Ability } from 'ember-can';

import SessionMixin from 'gistr/mixins/session';


export default Ability.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),

  canRead: function() {
    // Staff can read everything
    if (this.get('currentUser.isStaff')) { return true; }

    // If we're asked for trees in general, check that
    var tree = this.get('model');
    if (Ember.isNone(tree)) { return this.get('lifecycle.isInPlaying'); }

    // Else, check lifecycle and tree access
    var profileTrees = this.get('currentProfile.trees');
    return this.get('lifecycle.isInPlaying') && profileTrees.contains(tree);
  }.property('currentProfile.trees', 'currentProfile.isStaff', 'lifecycle.isInPlaying')
});
