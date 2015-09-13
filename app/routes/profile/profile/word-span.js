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
        trialsPerSetSize = this.get('shaping.wordSpanTrialsPerSetSize'),
        setSizes = {
          'training': this.get('shaping.wordSpanTrainingSetSizes'),
          'tasking': this.get('shaping.wordSpanTaskingSetSizes'),
        },
        summer = (acc, n) => acc + trialsPerSetSize * n,
        trainingWordCount = setSizes['training'].reduce(summer, 0),
        taskingWordCount = setSizes['tasking'].reduce(summer, 0),
        words = { 'training': [], 'tasking': [] },
        flatWords = sample(availableWords, trainingWordCount + taskingWordCount),
        index = 0;

    for (var tipe of ['training', 'tasking']) {
      for (var size of setSizes[tipe]) {
        for (var j = 0; j < trialsPerSetSize; j++) {
          words[tipe].push(flatWords.slice(index, index + size));
          index += size;
        }
      }
    }

    controller.set('words', words);
    controller.set('sessionCounts', {
      'training': setSizes['training'].length * trialsPerSetSize,
      'tasking': setSizes['tasking'].length * trialsPerSetSize
    });
  },
  scrollUp: function() {
    window.scrollTo(0, 0);
  }.on('activate')
});
