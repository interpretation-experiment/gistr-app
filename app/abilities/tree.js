import { Ability } from 'ember-can';

import SessionMixin from 'gistr/mixins/session';


export default Ability.extend(SessionMixin, {
  canRead: function() {
    // Staff can read everything
    if (this.get('currentProfile.isStaff')) { return true; }

    var tree = this.get('model'),
        profileTrees = this.get('currentProfile.trees');

    return profileTrees.contains(tree);
  }.property('currentProfile.trees', 'currentProfile.isStaff')
});
