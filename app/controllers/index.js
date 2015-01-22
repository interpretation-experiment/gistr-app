import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    // TODO: test
    setNickname: function() {
      var nickname = this.get('nickname');

      if (! /^[a-zA-Z][a-zA-Z0-9]*$/.test(nickname)) {
        this.set('error', 'Use only letters and numbers (starting with a letter)');
        return;
      }

      if (nickname.length < 3) {
        this.set('error', 'Use at least 3 letters');
        return;
      }

      this.set('nickname', nickname);
      this.set('hasNickname', true);
    },

    // TODO: test
    clearNickname: function() {
      this.set('error', undefined);
      this.set('nickname', undefined);
      this.set('hasNickname', false);
    }
  }
});
