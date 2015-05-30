import Ember from 'ember';


export default Ember.Service.extend({
  serverMeta: Ember.inject.service(),

  /*
   * Static parameters
   */
  readFactor: 1,              // multiplied by the number of tokens, gives seconds
  writeFactor: 5,             // multiplied by the number of tokens, gives seconds
  branchProbability: 0.8,     // probability of branching in a tree
  minTokens: 10,              // app-wide minimum number of tokens for sentences

  /*
   * Variable parameters, retrieved from server
   */
  targetBranchCount: null,
  targetBranchDepth: null,
  experimentWork: null,
  trainingWork: null,
  readingSpanWordsCount: null,
  readingSpanTrialsCount: null,

  _populationPromise: null,
  populate: function() {
    var self = this,
        _populationPromise = this.get('_populationPromise');

    if (!Ember.isNone(_populationPromise)) {
      return _populationPromise;
    }

    _populationPromise = this.get('serverMeta').populate().then(function(serverMeta) {
      var data = serverMeta.get('data');
      self.setProperties({
        targetBranchCount: data.target_branch_count,
        targetBranchDepth: data.target_branch_depth,
        experimentWork: data.experiment_work,
        trainingWork: data.training_work,
        readingSpanWordsCount: data.reading_span_words_count,
        readingSpanTrialsCount: data.reading_span_trials_count
      });
      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }
});
