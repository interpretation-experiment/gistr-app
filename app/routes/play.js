import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import RestrictedRouteMixin from 'gistr/mixins/restricted-route';


export default Ember.Route.extend(FormRouteMixin, RestrictedRouteMixin, {
  model: function() {
    // FIXME: load X trees in one go
  },

  activate: function() {
    this.controllerFor('play').watchUntouchedTreesCount();
  }
});
