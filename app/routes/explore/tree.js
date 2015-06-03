import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';


export default Ember.Route.extend(FormRouteMixin, {
  model: function(params) {
    return this.store.find('tree', params.tree_id);
  },

  scrollSpyEvent: 'scroll.tree-detail',
  setupScrollSpy: function() {
    var $window = Ember.$(window),
        lastSet, $graph, $path, top;

    $window.on(this.get('scrollSpyEvent'), function() {
      // Initialize our selectors
      if (Ember.isNone($graph)) { $graph = Ember.$('#tree-graph'); }
      if (Ember.isNone($path)) { $path = Ember.$('#path-detail'); }
      if (Ember.isNone(top)) { top = $graph.offset().top; }

      if ($window.scrollTop() > top - 10) {
        if (lastSet === true) { return; }
        lastSet = true;
        $graph.addClass('side-col-sm-6');
        $path.addClass('col-sm-offset-6');
      } else {
        if (lastSet === false) { return; }
        lastSet = false;
        $graph.removeClass('side-col-sm-6');
        $path.removeClass('col-sm-offset-6');
      }
    });
  }.on('activate'),
  closeScrollSpy: function() {
    Ember.$(window).off(this.get('scrollSpyEvent'));
  }.on('deactivate')
});
