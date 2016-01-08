import Ember from 'ember';

import shuffle from 'gistr/utils/shuffle';
import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin,
                                  SessionMixin, {
  /*
   * Utilities
   */
  lang: Ember.inject.service(),
  shaping: Ember.inject.service(),

  beforeModel: function(transition) {
    if (this._super(transition)) {
      return this.controllerFor('play').loadInfos();
    }
  },

  model: function() {
    // If in training, and there are available training trees,
    // get all the necessary trees for that in one go (or as many as
    // we can take). This way training doesn't repeat trees the user
    // already saw.
    // If there aren't enough distinct trees to do all the trainingWork,
    // the play controller will sample as normal once it uses up all these.
    // If there are no trees at all, this is skipped and the play controller
    // transitions to info anyway.
    if (this.get('lifecycle.currentState') === 'exp.training' &&
        this.get('currentProfile.availableTreesBucket') > 0) {
      var profile = this.get('currentProfile'),
          mothertongue = profile.get('mothertongue'),
          isOthertongue = mothertongue === this.get('lang.otherLanguage');

      var filter = {
        // In the proper language (this also assures the trees are not empty)
        root_language: isOthertongue ? this.get('lang.defaultLanguage') : mothertongue,
        with_other_mothertongue: isOthertongue,
        without_other_mothertongue: !isOthertongue,

        // Training bucket
        root_bucket: 'training',

        // Enough trees to finish training, if possible
        sample: this.get('shaping.trainingWork'),
      };

      return this.store.find('tree', filter).then(function(trees) {
        // We know there'll be at least one tree, we checked above
        // with availableTreesBucket
        return shuffle(trees.map(function(tree) {
          return tree.get('root');
        }));
      });
    }
  },
  setupController: function(controller, model) {
    if (this.get('lifecycle.currentState') === 'exp.training' &&
        !Ember.isNone(model)) {
      controller.set('trainingSentences', model);
    }
  },

  subscribeLifecycle: function() {
    this.get('lifecycle').subscribe('play', this.controllerFor('play'));
  }.on('activate'),
  unsubscribeLifecycle: function() {
    this.get('lifecycle').unsubscribe('play');
  }.on('deactivate')
});
