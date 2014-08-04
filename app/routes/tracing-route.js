export default Ember.Route.extend({
  beforeModel: function(transition) {
    var originName = transition.originName;
    var authorizedOrigins = this.get('authorizedOrigins');
    var unauthorizedOriginRedirect = this.get('unauthorizedOriginRedirect');
    Ember.Logger.log("Transition #" + transition.sequence +
                     ": to TracingRoute: " + originName +
                     " -> " + transition.targetName);

    // Bark if authorizedOrigins is defined but not a list
    if (!!authorizedOrigins && !(authorizedOrigins instanceof Array)) {
      var err1 = "TracingRoute '" + this.get('routeName') +
                 "' has defined 'authorizedOrigins' but it's not a list.";
      Ember.Logger.error(err1);
      throw new Error(err1);
    }

    // Bark if we have nowhere to redirect to (independent of redirection)
    if (!!authorizedOrigins && !unauthorizedOriginRedirect) {
      var err2 = "TracingRoute '" + this.get('routeName') +
                 "' has defined 'authorizedOrigins' but no " +
                 "'unauthorizedOriginRedirect'.";
      Ember.Logger.error(err2);
      throw new Error(err2);
    }

    // originName can be undefined, this should still apply
    if (!!authorizedOrigins &&
        !authorizedOrigins.contains(originName)) {
      Ember.Logger.log("Transition #" + transition.sequence + ": comes from " +
                       originName + " which is not in authorizedOrigins (" +
                       JSON.stringify(authorizedOrigins) + "). Redirecting to " +
                       unauthorizedOriginRedirect);
      this.transitionTo(unauthorizedOriginRedirect);
    }
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
