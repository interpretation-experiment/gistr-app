import Ember from 'ember';

import IntroJSComponent from 'ember-introjs/components/intro-js';

import SessionMixin from 'gistr/mixins/session';


export default IntroJSComponent.extend(SessionMixin, {
  lifecycle: Ember.inject.service(),
  shaping: Ember.inject.service(),

  initIntroJS: function() {
    if (this.get('lifecycle.isInExp')) {
      this.set('steps', this.get('getExpSteps')(this.get('currentUser'),
                                                this.get('shaping'),
                                                this.get('lifecycle')));
    } else if (this.get('lifecycle.isInPlaying')) {
      this.set('steps', this.get('getPlayingSteps')(this.get('currentUser'),
                                                    this.get('shaping'),
                                                    this.get('lifecycle')));
    } else {
      console.warn(`Asked to do an intro for unknown ` +
                   `lifecycle state '${this.get('lifecycle.currentState')}'`);
    }
  }.on('didInsertElement')
});
