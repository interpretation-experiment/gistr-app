import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, {
  beforeModel: function() {
    if (this.get('currentProfile.questionnaireDone')) {
      this.transitionTo('profile.profile');
    }
  },
  scrollUp: function() {
    window.scrollTo(0, 0);
  }.on('activate')
});
