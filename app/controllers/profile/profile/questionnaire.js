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
    upload: function(callback) {
      callback(this.upload());
    },
  }
});
