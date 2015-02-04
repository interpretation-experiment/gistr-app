import Ember from 'ember';

export default Ember.ObjectController.extend(Ember.FSM.Stateful, {
  /*
   * Input validation variables
   */
  text: null,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      text: null,
      errors: null,
      isUploading: null
    });
  },

  /*
   * Input upload
   */
  _uploadSentence: function() {
    var self = this;

    this.set('isUploading', true);
    this.get('store').createRecord('sentence', {
      text: this.get('text')
    }).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
    });
  },

  /*
   * Global reset
   */
  reset: function() {
    this.resetInput();
  },

  /*
   * Suggestion control
   */
  canSuggest: function() {
    var user = this.get('session').get('currentUser');
    // Staff can always suggest
    if (this.get('session').get('currentUser').get('is_staff')) {
      return true;
    }

    return user.get('profile').then(function(profile) {
      console.log('Can suggest: ' + (profile.get('suggestion_credit') > 0));
      return profile.get('suggestion_credit') > 0;
    });
  }.property('session.currentUser.profile.suggestion_credit'),

  /*
   * Suggestion actions
   */
  actions: {
    suggest: function() {
      this.sendStateEvent('suggest');
    },
    reset: function() {
      this.sendStateEvent('reset');
    },
    uploadSentence: function() {
      this._uploadSentence();
    }
  },

  /*
   * Suggestion FSM states and events
   */
  fsmStates: {
    initialState: 'suggesting',
    suggesting: {
      didExit: 'resetInput'
    },
    verified: {
      didEnter: function() {
        this.get('session').get('currentUser').get('profile').then(function(profile) {
          profile.reload();
        });
      }
    }
  },
  fsmEvents: {
    suggest: {
      transition: { verified: 'suggesting' }
    },
    upload: {
      transition: { suggesting: 'verified' }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial',
        didEnter: 'reset'
      }
    }
  }
});
