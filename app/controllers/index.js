import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import ProlificMixin from 'gistr/mixins/prolific';


export default Ember.Controller.extend(SessionMixin, ProlificMixin, {
  expIntroNotDone: Ember.computed.not('currentProfile.introducedExpHome'),
  playIntroNotDone: Ember.computed.not('currentProfile.introducedPlayHome'),
  doExpIntro: Ember.computed.and('lifecycle.isInExp', 'expIntroNotDone'),
  doPlayIntro: Ember.computed.and('lifecycle.isInPlaying', 'playIntroNotDone'),
  manualIntro: false,
  showIntro: Ember.computed.or('doExpIntro', 'doPlayIntro', 'manualIntro'),

  actions: {
    showIntro: function() {
      this.set('manualIntro', true);
    },
    expIntroDone: function() {
      this.set('manualIntro', false);
      this.get('currentProfile').set('introducedExpHome', true).save();
    },
    playIntroDone: function() {
      this.set('manualIntro', false);
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
    var have = user.get('profile.suggestionCredit') > 0 ? 'do' : "don't, yet";
    return [
      {
        element: Ember.$('#title').get(0),
        intro: "Welcome back! You're in play mode now :-)"
      },
      {
        element: Ember.$('#play').get(0),
        intro: "You can continue transforming texts",
        position: 'right'
      },
      {
        element: Ember.$('#new').get(0),
        intro: `If you have credits (you ${have}), you can suggest your own texts!`,
        position: 'right'
      },
      {
        element: Ember.$('#explore').get(0),
        intro: "You can also explore what transformations other people did",
        position: 'left'
      },
      {
        element: Ember.$('#reports').get(0),
        intro: "Or you can have a peek at the results from the experiment, and see how you did compared to the other participants!",
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
