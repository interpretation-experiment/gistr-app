import Ember from 'ember';


export default Ember.Controller.extend({
  questionnaireChoices: Ember.inject.service(),

  showNaiveDetail: false,

  actions: {
    reset: function() {
      // Nothing for now
    },
    toggleNaiveDetail: function() {
      this.set('naiveDetail', '');
      this.toggleProperty('showNaiveDetail');
      if (this.get('showNaiveDetail')) {
        this.set('notNaive', true);
      }
    },
  }
});
