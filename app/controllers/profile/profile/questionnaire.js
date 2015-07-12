import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  questionnaireChoices: Ember.inject.service(),

  /*
   * Form fields and reset
   */
  age: null,
  gender: null,
  informed: false,
  informedHow: null,
  informedWhat: null,
  jobType: null,
  jobFreetext: null,
  errors: null,
  isUploading: false,
  isConfirming: false,
  resetInput: function() {
    this.setProperties({
      age: null,
      gender: null,
      informed: false,
      informedHow: null,
      informedWhat: null,
      jobType: null,
      jobFreetext: null,
      errors: null,
      isUploading: false,
      isConfirming: false,
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
        data = this.getProperties('age', 'gender',
                                  'informed', 'informedHow', 'informedWhat',
                                  'jobType', 'jobFreetext');

    if (!data.informed) { data.informedHow = data.informedWhat = '-----'; }

    this.set('isUploading', true);
    this.set('isConfirming', false);
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
   * Form validation
   */
  isUploadingOrConfirming: Ember.computed.or('isUploading', 'isConfirming'),
  validate: function() {
    var errors = {},
        data = this.getProperties('age', 'gender',
                                  'informed', 'informedHow', 'informedWhat',
                                  'jobType', 'jobFreetext');

    // Age
    var age = Number(data.age);
    if (!data.age || !Number.isInteger(age)) { errors.age = "Please enter a number"; }
    else if (age < 3) { errors.age = "This should be greater than or equal to 3"; }
    else if (age > 120) { errors.age = "This should be lower than or equal to 120"; }

    // Gender
    if (!data.gender) { errors.gender = "Please choose a gender"; }

    // Naive/informed
    if (data.informed) {
      if (!data.informedHow || data.informedHow.length < 5) { errors.informedHow = "Please type at least 5 letters"; }
      else if (data.informedHow.length > 500) { errors.informedHow = "This field can't be more than 500 characters long"; }
      if (!data.informedWhat || data.informedWhat.length < 5) { errors.informedWhat = "Please type at least 5 letters"; }
      else if (data.informedWhat.length > 500) { errors.informedWhat = "This field can't be more than 500 characters long"; }
    }

    // Job
    if (!data.jobType) { errors.jobType = "Please select a category"; }
    if (!data.jobFreetext || data.jobFreetext.length < 5) { errors.jobFreetext = "Please type at least 5 letters"; }
    else if (data.jobFreetext.length > 500) { errors.jobFreetext = "This field can't be more than 500 characters long"; }

    if (Object.keys(errors).length > 0) {
      this.set('errors', errors);
      return false;
    }

     return true;
  },

  /*
   * Informed text control
   */
  watchInformed: function() {
    this.set('informedHow', null);
    this.set('informedWhat', null);
  }.observes('informed'),

  actions: {
    reset: function() {
      this.reset();
    },
    confirm: function() {
      this.set('errors', null);
      if (this.validate()) {
        window.scrollTo(0, 0);
        this.set('isConfirming', true);
      }
    },
    infirm: function() {
      this.set('isConfirming', false);
    },
    upload: function(callback) {
      callback(this.upload());
    },
  }
});
