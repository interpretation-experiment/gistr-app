import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),
  questionnaireChoices: Ember.inject.service(),

  /*
   * Form fields and reset
   */
  showNaiveDetail: false,
  age: null,
  gender: null,
  notNaive: false,
  naive: Ember.computed.not('notNaive'),
  naiveDetail: "",
  errors: null,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      showNaiveDetail: false,
      age: null,
      gender: null,
      notNaive: false,
      naiveDetail: "",
      errors: null,
      isUploading: false,
    });
  },
  reset: function() {
    this.resetInput();
  },

  /*
   * Form upload
   */
  upload: function() {
    var self = this,
        lifecycle = this.get('lifecycle'),
        profile = this.get('currentProfile'),
        data = this.getProperties('age', 'gender', 'naive', 'naiveDetail'),
        forward = 'profile';

    // FIXME: this stubs out isco stuff
    data['iscoMajor'] = "1";
    data['iscoSubmajor'] = "11";
    data['iscoMinor'] = "111";

    this.set('isUploading', true);
    return this.get('store').createRecord('questionnaire', data).save().then(function() {
      return profile.reload();
    }).then(function() {
      self.resetInput();

      // Transition lifecycle state if possible
      if (lifecycle.get('validator.isComplete')) {
        // We can transition, so move the user to the exp
        if (lifecycle.get('isInExpTraining')) { forward = 'index'; }
        return lifecycle.transitionUp();
      }

      // If the user is done with his profile, move him to his training in 'play'
      if (!lifecycle.get('validator.actionRoutes').contains('profile')) {
        forward = 'index';
      }
    }).then(function() {
      self.transitionToRoute(forward);
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },

  actions: {
    reset: function() {
      this.reset();
    },
    upload: function(callback) {
      callback(this.upload());
    },
    toggleNaiveDetail: function() {
      this.set('naiveDetail', '');
      this.toggleProperty('showNaiveDetail');
      if (this.get('showNaiveDetail')) {
        this.set('notNaive', true);
      }
    },
  }
});
