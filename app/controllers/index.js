import Ember from 'ember';

export default Ember.Controller.extend({
  // TODO: test
  _setNickname: function(nickname) {
    if (! /^[a-zA-Z][a-zA-Z0-9]*$/.test(nickname)) {
      this.set('error', 'Use only letters and numbers (starting with a letter)');
      return;
    }

    if (nickname.length < 3) {
      this.set('error', 'Use at least 3 letters');
      return;
    }

    this.set('nickname', nickname);
    localStorage.nickname = nickname;
    this.set('hasNickname', true);
  },

  // TODO: test
  _clearNickname: function() {
    this.set('error', undefined);
    this.set('nickname', undefined);
    delete localStorage.nickname;
    this.set('hasNickname', false);
  },

  actions: {
    setNickname: function() {
      this._setNickname(this.get('nickname'));
    },

    clearNickname: function() {
      this._clearNickname();
    }
  }
});
