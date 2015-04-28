import Ember from 'ember';


export default Ember.Component.extend({
  chart: null,

  // This is only useful for initialization, so that the first progress
  // value (when initializing in `chartify()`) is correct. Updates to this
  // attribute are not used by easyPieChart, instead we do the update
  // in `updateValue()`.
  attributeBindings: ['value:data-percent'],

  chartify: function() {
    var $el = Ember.$(this.get('element'));

    $el.easyPieChart({
      barColor: d3.scale.linear().domain([0, 80, 100]).range(["green", "orange", "red"]),
      scaleColor: '#e0e3e7',
      animate: false
    });
    this.set('chart', $el.data('easyPieChart'));
  }.on('didInsertElement'),

  updateValue: function() {
    var chart = this.get('chart');

    if (Ember.isNone(chart)) { return; }
    chart.update(this.get('value'));
  }.observes('value')
});
