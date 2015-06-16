import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';


export default Ember.Route.extend(FormRouteMixin, {
  clearProlificId: function() {
    this.controllerFor('prolific').send('clearProlificId');
  }.on('activate')
});
