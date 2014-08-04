export default Ember.Route.extend({
  actions: {
    willTransition: function(transition){
      this._willTransition(transition);
    }
  },

  _willTransition: function(transition) {
    transition.originName = this.routeName;
  }
});
