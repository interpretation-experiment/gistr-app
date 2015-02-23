import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin, {
  model: function() {
    // FIXME: load X trees in one go
  },

  activate: function() {
    this.controllerFor('play').watchUntouchedTreesCount();
  }
});
