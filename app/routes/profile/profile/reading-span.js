import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, ProfileRouteMixin, {
  beforeModel: function(transition) {
    if (this._super(transition)) {
      if (this.get('currentProfile.readingSpanDone')) {
        this.transitionTo('profile.profile');
      }
    }
  },
  scrollUp: function() {
    window.scrollTo(0, 0);
  }.on('activate')
});
