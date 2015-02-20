import Ember from 'ember';
import RestrictedRouteMixin from './restricted';
import FormRouteMixin from './form';

export default Ember.Route.extend(RestrictedRouteMixin, FormRouteMixin, {
  model: function() {
    // FIXME: load X trees in one go
  },
  activate: function() {
    this.controllerFor('play').watchUntouchedTreesCount();
  }
});
