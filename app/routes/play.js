import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import config from 'gistr/config/environment';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin, {
  watchAvailableTreesCount: function() {
    this.controllerFor('play').watchAvailableTreesCount();
  }.on('activate')
});
