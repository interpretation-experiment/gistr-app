import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import sample from 'gistr/utils/sample';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, ProfileRouteMixin, {
  shaping: Ember.inject.service(),

  beforeModel: function(transition) {
    if (this._super(transition)) {
      if (this.get('currentProfile.readingSpanDone')) {
        this.transitionTo('profile.profile');
      }
    }
  },
  setupController: function(controller/*, model*/) {
    var availableWords = this.get('shaping.readingSpanWords'),
        trialsCount = this.get('shaping.readingSpanTrialsCount'),
        wordsCount = this.get('shaping.readingSpanWordsCount'),
        words = [],
        flatWords = sample(availableWords, trialsCount * wordsCount);

    for (var i = 0; i < trialsCount; i++) {
      words.push(flatWords.slice(i * wordsCount, (i + 1) * wordsCount).map(function(word) {
        return word.capitalize();
      }));
    }

    controller.set('words', words);
  },
  scrollUp: function() {
    window.scrollTo(0, 0);
  }.on('activate')
});
