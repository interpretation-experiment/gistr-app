import RestrictedRoute from './restricted-route';

export default RestrictedRoute.extend({
  deactivate: function() {
    this.get('controller').send('reset');
  }
});
