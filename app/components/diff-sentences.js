import Ember from 'ember';


export default Ember.Component.extend({
  classNames: ['diff-container'],

  dmp: function() {
    return new diff_match_patch();
  }.property(),

  diffs: function() {
    var dmp = this.get('dmp'),
        text1 = this.get('sentence1.text'),
        text2 = this.get('sentence2.text');

    if (Ember.isNone(text1) || Ember.isNone(text2)) { return; }

    var diffs = dmp.diff_main(text1, text2);
    dmp.diff_cleanupSemantic(diffs);
    return diffs;
  }.property('sentence1', 'sentence2')
});
