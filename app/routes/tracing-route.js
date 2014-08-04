export default Ember.Route.extend({
  beforeModel: function(transition) {
    Ember.Logger.log("Transition #" + transition.sequence + ": to TracingRoute: " +
                     transition.originName + " -> " + transition.targetName);
  },

  actions: {
    willTransition: function(transition){
      this._willTransition(transition);
    }
  },

  _willTransition: function(transition) {
    transition.originName = this.get('routeName');
    Ember.Logger.log("Transition #" + transition.sequence + ": from TracingRoute: " +
                     transition.originName + " -> " + transition.targetName);
  }
});
