import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  expIntroNotDone: Ember.computed.not('currentProfile.introducedExpHome'),
  doExpIntro: Ember.computed.and('lifecycle.isInExp', 'expIntroNotDone'),
  playIntroNotDone: Ember.computed.not('currentProfile.introducedPlayHome'),
  doPlayIntro: Ember.computed.and('lifecycle.isInPlaying', 'playIntroNotDone'),

  actions: {
    expIntroComplete: function() {
      this.get('currentProfile').set('introducedExpHome', true).save();
    },
    playIntroComplete: function() {
      this.get('currentProfile').set('introducedPlayHome', true).save();
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
  playIntroSteps: function(user) {
    var have = user.get('profile.suggestionCredit') > 0 ? 'do' : "don't";
    return [
      {
        element: Ember.$('#title').get(0),
        intro: "Welcome back! You're in play mode now :-)"
      },
      {
        element: Ember.$('#play').get(0),
        intro: "You can continue transforming sentences",
        position: 'right'
      },
      {
        element: Ember.$('#explore').get(0),
        intro: "Or you can also explore what transformations other people did",
        position: 'right'
      },
      {
        element: Ember.$('#new').get(0),
        intro: `And if you have credits (you ${have}), you can suggest your own sentences!`,
        position: 'left'
      },
      {
        element: Ember.$('#about-gistr').get(0),
        intro: `Look over here to learn all about the experiment!`,
        position: 'top'
      },
    ];
  }
});
