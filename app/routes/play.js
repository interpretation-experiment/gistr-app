import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin, {
  initPlayState: function() {
    this.controllerFor('play').send('init');
  }.on('activate')
});
