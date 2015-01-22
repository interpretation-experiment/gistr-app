import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    pickUsername: function() {
      var controller = this.controllerFor('index'),
          nickname = controller.get('nickname');

      if (! /^[a-zA-Z][a-zA-Z0-9]*$/.test(nickname)) {
        controller.set('error', 'Use only letters and numbers (starting with a letter)');
        return;
      }

      if (nickname.length < 3) {
        controller.set('error', 'Use at least 3 letters');
        return;
      }

      controller.set('hasNickname', true);
    }
  }
});
