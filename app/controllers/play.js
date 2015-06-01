import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import EventfulMixin from 'gistr/mixins/eventful';
import draw from 'gistr/utils/draw';
import splitEvent from 'gistr/utils/split-event';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, EventfulMixin, {
  /*
   * Language utilities
   */
  lang: Ember.inject.service(),

  /*
   * General parameters
   */
  shaping: Ember.inject.service(),

  /*
   * Global progress and reset
   */
  expProgress: function() {
    return 100 * this.get('currentProfile.reformulationsCount') / this.get('shaping.experimentWork');
  }.property('currentProfile.reformulationsCount', 'shaping.experimentWork'),
  trainingProgress: function() {
    return 100 * this.get('streak') / this.get('shaping.trainingWork');
  }.property('streak', 'shaping.trainingWork'),
  streak: 0,
  resetStreak: function() {
    this.set('streak', 0);
  }.observes('lifecycle.currentState'),

  reset: function() {
    this.resetEvents();
    this.resetStreak();
    this.resetModels();
  },
  reloadTree: function() {
    return this.get('currentSentence.tree').then(function(tree) {
      return tree.reload();
    });
  },

  /*
   * Introductions
   */
  expIntroNotDone: Ember.computed.not('currentProfile.introducedExpPlay'),
  doExpIntro: Ember.computed.and('lifecycle.isInExp', 'expIntroNotDone'),
  playIntroNotDone: Ember.computed.not('currentProfile.introducedPlayPlay'),
  doPlayIntro: Ember.computed.and('lifecycle.isInPlaying', 'playIntroNotDone'),

  /*
   * Streak-related events
   */
  eventChecks: {
    'playing:gain:new-credit': {
      check: function(prev) {
        return this.get('currentProfile.suggestionCredit') === prev + 1;
      },
      observes: 'currentProfile.suggestionCredit'
    },
    'exp.doing:rhythm:break': {
      check: function(prev) {
        var streak = this.get('streak');
        return streak === prev + 1 && streak !== 0 && streak % 10 === 0;
      },
      observes: 'streak'
    },
    'playing:rhythm:diff-break': {
      check: function(prev) {
        var streak = this.get('streak');
        return streak === prev + 1 && streak !== 0 && streak % 3 === 0;
      },
      observes: 'streak'
    },
    'playing:rhythm:exploration-break': {
      check: function(prev) {
        var streak = this.get('streak');
        return streak === prev + 1 && streak !== 0 && streak % 5 === 0;
      },
      observes: 'streak'
    }
  },
  eventFilter: function(event) {
    return splitEvent(event).state === this.get('lifecycle.currentState');
  },

  loadInfos: function() {
    var self = this,
        lifecycle = this.get('lifecycle'),
        validator = lifecycle.get('validator');

    return this.get('currentProfile').reload().then(function() {
      // Transition state if possible
      if (validator.get('isComplete')) {
        return lifecycle.transitionUp();
      }
    }).then(function() {
      var events = self.get('events');

      // Should we inform?
      if (events.length > 0) {
        self.sendStateEvent('inform');
      } else if (!validator.get('isComplete') && !validator.get('actionRoutes').contains('play')) {
        // We have no events but our cycle is incomplete,
        // and nothing in the play route can help advance it.
        self.sendStateEvent('inform');
      } else if (self.get('currentProfile.availableTreesBucket') === 0) {
        // No more sentences, even after our possible transition to the new state
        self.sendStateEvent('inform');
      } else {
        // Let the user read the instructions if we're there
        if (self.get('currentState') !== 'instructions') {
          self.sendStateEvent('task.read');
        }
      }
    });
  },

  /*
   * Current tree and sentence state and selection
   */
  currentSentence: null,
  resetModels: function() {
    this.setProperties({
      currentSentence: null
    });
  },
  drawInTree: function(tree) {
    var branchesCount = tree.get('branchesCount'),
        targetBranchCount = this.get('shaping.targetBranchCount'),
        pBranch = this.get('shaping.branchProbability'),
        root = tree.get('root'),
        tips = tree.get('tips'),
        effectiveTips = tips.underTips.length === 0 ?
            tips.overflownTips : tips.underTips;

    // If we only have a root, return fast
    if (tips.allTips.length === 0) { return root; }

    // Could we branch?
    if (branchesCount < targetBranchCount) {
      // Yes. Should we branch?
      if (Math.random() < pBranch) {
        // Yes, so return root
        return root;
      } else {
        // No. So draw an existing branch and a tip inside it
        // (hence the double `draw`), and return
        return this.store.find('sentence', draw(draw(effectiveTips)));
      }
    } else {
      // No. Draw from an existing branch.
      return this.store.find('sentence', draw(draw(effectiveTips)));
    }
  },
  selectModels: function() {
    // FIXME: evaluate if this can be moved to route, and break the cycle?
    var self = this, profile = this.get('currentProfile'),
        mothertongue = profile.get('mothertongue'),
        isOthertongue = mothertongue === this.get('lang.otherLanguage');

    var unshapedFilter = {
      // The tree is yet unseen
      untouched_by_profile: profile.get('id'),

      // In the proper language (this also assures the tree is not empty)
      root_language: isOthertongue ? this.get('lang.defaultLanguage') : mothertongue,
      with_other_mothertongue: isOthertongue,
      without_other_mothertongue: !isOthertongue,

      // Gistr bucket: experiment or game
      root_bucket: this.get('lifecycle.bucket'),

      // One random tree from the filtered list
      sample: 1,
    };

    var shapedFilter = Ember.setProperties(Ember.copy(unshapedFilter), {
      // Filter with proper shape (we want either branches_count or shortest_branch_depth
      // to be one less than these limits, but if unlucky enough to get a tree
      // that was just completed, we'll lengthen one of its branches)
      branches_count_lte: this.get('shaping.targetBranchCount'),
      shortest_branch_depth_lte: this.get('shaping.targetBranchDepth'),
    });

    return this.store.find('tree', shapedFilter).then(function(trees) {
      if (trees.length === 0) {
        // We're out of luck, all the available trees are already full! Still, get one of those
        return self.store.find('tree', unshapedFilter);
      } else {
        return trees;
      }
    }).then(function(trees) {
      // We got a tree! Draw from it
      return self.drawInTree(trees.objectAt(0));
    }).then(function(sentence) {
      // Finally, set the drawn sentence
      self.set('currentSentence', sentence);
    });
  },

  /*
   * Trial progress actions
   */
  actions: {
    expIntroDone: function() {
      this.get('currentProfile').set('introducedExpPlay', true).save();
    },
    playIntroDone: function() {
      this.get('currentProfile').set('introducedPlayPlay', true).save();
    },
    'task.read': function() {
      this.sendStateEvent('task.read');
    },
    'task.distract': function() {
      this.sendStateEvent('task.distract');
    },
    'task.write.user': function() {
      this.sendStateEvent('task.write.user');
    },
    'task.timeout': function() {
      this.sendStateEvent('task.timeout');
    },
    processWriting: function() {
      this.incrementProperty('streak');
      this.sendStateEvent('task.write.process');
    },
    instruct: function() {
      this.sendStateEvent('instruct');
    },
    reset: function() {
      this.sendStateEvent('reset');
    },

    /*
     * Lifecycle watching
     */
    'lifecycle.update': function(event) {
      if (event.value) {
        console.log(`[play] setting event ${event.name}`);
        this.pushEvent(this.get('lifecycle.currentState') + ':lifecycle:' + event.name);
      }
    }
  },

  /*
   * Trial progress FSM states and events
   */
  fsmStates: {
    initialState: 'instructions',
    knownStates: ['instructions', 'task.reading', 'task.distracting', 'task.writing.user',
                  'task.writing.processing', 'task.timedout', 'info', 'failed'],
    'task.reading': {
      willEnter: 'selectModels'
    }
  },
  fsmEvents: {
    'task.read': {
      transitions: [
        {
          from: ['instructions', 'task.writing.processing', 'task.timedout'],
          to: 'task.reading'
        },
        {
          info: 'task.reading',
          after: 'resetEvents'
        }
      ]
    },
    'task.distract': {
      transition: { 'task.reading': 'task.distracting' }
    },
    'task.write.user': {
      transition: { 'task.distracting': 'task.writing.user' }
    },
    'task.timeout': {
      transition: { 'task.writing.user': 'task.timedout' }
    },
    // TODO: use loading slider for this
    // TODO: bumpStreak to here
    'task.write.process': {
      transition: {
        from: 'task.writing.user',
        to: 'task.writing.processing',
        enter: 'reloadTree',
        after: 'loadInfos'
      }
    },
    inform: {
      transition: {
        from: ['instructions', 'task.writing.processing'],
        to: 'info'
      }
    },
    instruct: {
      transition: { info: 'instructions' }
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
