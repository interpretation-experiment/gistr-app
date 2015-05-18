import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  doIntro: false,
  actions: {
    introComplete: function() {
      this.set('doIntro', false);
    },
  },

  expIntroSteps: function() {
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
        element: Ember.$('#pass').get(0),
        intro: "Get going on the experiment now! You'll get to know all about it afterwards."
      }
    ];
  },
  playingIntroSteps: function() {}
});
