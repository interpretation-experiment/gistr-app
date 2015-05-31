import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';
import EnterNextMixin from 'gistr/mixins/enter-next';


export default Ember.Component.extend(TimefulMixin, EnterNextMixin, {
  shaping: Ember.inject.service(),

  duration: function() {
    return this.get('shaping.readFactor') * this.get('shaping.readingSpanWordsCount');
  }.property('shaping.readFactor', 'sentenceTokensCount'),

  timerDone: function() {
    this.sendAction('next');
  },
  onEnter: function() {
    this.send('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
