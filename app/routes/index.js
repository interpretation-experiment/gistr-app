import Ember from 'ember';

export default Ember.Route.extend({
  // TODO: test
  setupController: function(controller, model) {
    this._super(controller, model);

    if ('nickname' in localStorage) {
      controller._setNickname(localStorage.nickname);
    }
  }
});
