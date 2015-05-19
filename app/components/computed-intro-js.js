import Ember from 'ember';

import IntroJSComponent from 'ember-introjs/components/intro-js';

import SessionMixin from 'gistr/mixins/session';


export default IntroJSComponent.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),
  shaping: Ember.inject.service(),

  initIntroJS: function() {
    this.set('steps', this.get('getSteps')(this.get('currentUser'),
                                           this.get('shaping'),
                                           this.get('lifecycle')));
  }.on('didInsertElement')
});
