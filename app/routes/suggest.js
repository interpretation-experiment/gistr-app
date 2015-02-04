import RestrictedRoute from './restricted-route';

export default RestrictedRoute.extend({
  actions: {
    willTransition: function(/*transition*/) {
      this.get('controller').send('reset');
    }
  }
});
