import RestrictedRoute from './restricted-route';

export default RestrictedRoute.extend({
  model: function() {
    return this.store.filter('tree', {
      untouched: true,
      page_size: 10,
      sample: true
    }, function(tree) {
      return tree.get('untouched');
    });
  },
  setupController: function(controller, trees) {
    console.log(trees);
    controller.set('untouchedTrees', trees);
  },
  actions: {
    willTransition: function(/*transition*/) {
      this.get('controller').send('reset');
    }
  }
});
