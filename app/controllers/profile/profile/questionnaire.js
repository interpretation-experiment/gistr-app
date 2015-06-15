import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  questionnaireChoices: Ember.inject.service(),

  /*
   * Form fields and reset
   */
  age: null,
  gender: null,
  notNaive: false,
  naive: Ember.computed.not('notNaive'),
  naiveDetail: "",
  showNaiveDetail: false,
  iscoMajor: null,
  iscoSubmajor: null,
  iscoMinor: null,
  iscoFreetext: "",
  showIscoFreetext: false,
  errors: null,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      age: null,
      gender: null,
      notNaive: false,
      naiveDetail: "",
      showNaiveDetail: false,
      iscoMajor: null,
      iscoSubmajor: null,
      iscoMinor: null,
      iscoFreetext: "",
      showIscoFreetext: false,
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
        data = this.getProperties('age', 'gender', 'naive', 'naiveDetail',
                                  'iscoMajor', 'iscoSubmajor', 'iscoMinor',
                                  'iscoFreetext');

    this.set('isUploading', true);
    return this.get('store').createRecord('questionnaire', data).save().then(function() {
      return profile.reload();
    }).then(function() {
      self.resetInput();

      // Transition lifecycle state if possible
      if (lifecycle.get('validator.isComplete')) {
        return lifecycle.transitionUp();
      }
    }).then(function() {
      self.transitionToRoute('profile');
      // Scroll back up
      window.scrollTo(0, 0);
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },

  /*
   * Questionnaire choices
   */
  clearIscoSubmajor: function() {
    if (!this.get('showIscoFreetext')) {
      this.set('iscoSubmajor', null);
    }
  }.observes('iscoMajor'),
  clearIscoMinor: function() {
    if (!this.get('showIscoFreetext')) {
      this.set('iscoMinor', null);
    }
  }.observes('iscoSubmajor'),
  iscoSubmajorChoices: function() {
    var iscoMajor = this.get('iscoMajor');
    return this.get('questionnaireChoices.iscoSubmajors').filter(function(choice) {
      return choice.name.slice(0, 1) === iscoMajor;
    });
  }.property('questionnaireChoices.iscoSubmajors', 'iscoMajor'),
  iscoMinorChoices: function() {
    var iscoSubmajor = this.get('iscoSubmajor');
    return this.get('questionnaireChoices.iscoMinors').filter(function(choice) {
      return choice.name.slice(0, 2) === iscoSubmajor;
    });
  }.property('questionnaireChoices.iscoMinors', 'iscoSubmajor'),

  userJustSetNaive: false,
  watchUserNotNaive: function() {
    if (this.get('showNaiveDetail') && !this.get('userJustSetNaive')) {
      this.send('toggleNaiveDetail');
    }
  }.observes('notNaive'),

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
        this.set('userJustSetNaive', true);
        this.set('notNaive', true);
        this.set('userJustSetNaive', false);
      }
    },
    toggleIscoFreetext: function() {
      this.set('iscoFreetext', '');
      this.toggleProperty('showIscoFreetext');
      if (this.get('showIscoFreetext')) {
        this.setProperties({
          'iscoMajor': '-',
          'iscoSubmajor': '--',
          'iscoMinor': '---'
        });
      } else {
        this.setProperties({
          'iscoMajor': null,
          'iscoSubmajor': null,
          'iscoMinor': null
        });
      }
    },
  }
});
