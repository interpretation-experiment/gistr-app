import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin, {
  beforeModel: function(transition) {
    if (this._super(transition)) {
      return this.controllerFor('play').loadInfos();
    }
  },
});
