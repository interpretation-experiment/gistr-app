import IntroJSComponent from 'ember-introjs/components/intro-js';


export default IntroJSComponent.extend({
  lifecycle: Ember.inject.service(),

  initIntroJS: function() {
    if (this.get('lifecycle.isInExp')) {
      this.set('steps', this.get('getExpSteps')());
    } else if (this.get('lifecycle.isInPlaying')) {
      this.set('steps', this.get('getPlayingSteps')());
    } else {
      throw new Error(`Asked to do an intro for unknown ` +
                      `lifecycle state '${this.get('lifecycle.currentState')}'`);
    }
  }.on('didInsertElement')
});
