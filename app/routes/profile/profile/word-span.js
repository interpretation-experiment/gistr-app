import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import sample from 'gistr/utils/sample';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, ProfileRouteMixin, {
  shaping: Ember.inject.service(),

  beforeModel: function(transition) {
    if (this._super(transition)) {
      if (this.get('currentProfile.wordSpanDone')) {
        this.transitionTo('profile.profile');
      }
    }
  },
  setupController: function(controller/*, model*/) {
    var availableWords = this.get('shaping.wordSpanWords'),
        trialsCount = this.get('shaping.wordSpanTrialsCount'),
        wordsCount = this.get('shaping.wordSpanWordsCount'),
        words = [],
        flatWords = sample(availableWords, trialsCount * wordsCount);

    for (var i = 0; i < trialsCount; i++) {
      words.push(flatWords.slice(i * wordsCount, (i + 1) * wordsCount));
    }

    controller.set('words', words);
  },
  scrollUp: function() {
    window.scrollTo(0, 0);
  }.on('activate')
});
