import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';


export default Ember.Route.extend(FormRouteMixin, {
  setupController: function(controller) {
    if(!Ember.isNone(localStorage.prolificId)) {
      controller.set('isProlific', true);
    }
  }
});
