import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  needs: ['play'],

  doIntro: false,
  actions: {
    introComplete: function() {
      // TODO: save a introducedIndex${lifecycle.currentState} flag on the profile
      this.set('doIntro', false);
      this.get('controllers.play').set('doIntro', true);
    },
  },

  expIntroSteps: function(user) {
    return [
      {
        element: Ember.$('#title').get(0),
        intro: 'Hi! Welcome to the Gistr Experiment :-)'
      },
      {
        element: Ember.$('#profile').get(0),
        position: 'left',
        intro: "<p>There are a few tests and a questionnaire in your profile page.</p><p>Feel free to do them when you want to!</p>"
      },
      {
        element: Ember.$(user.get('isStaff') ? '#play' : '#pass').get(0),
        position: user.get('isStaff') ? 'right' : 'bottom',
        intro: "Get going on the experiment now! You'll get to know all about it afterwards."
      }
    ];
  },
  playingIntroSteps: function(/*user*/) {}
});
