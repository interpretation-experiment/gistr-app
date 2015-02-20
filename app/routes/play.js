import RestrictedRoute from './restricted-route';

export default RestrictedRoute.extend({
  model: function() {
    // FIXME: load X trees in one go
  },
  activate: function() {
    this.controllerFor('play').watchUntouchedTreesCount();
  },
  deactivate: function() {
    this.get('controller').send('reset');
  }
});
