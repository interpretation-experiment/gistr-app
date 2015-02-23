import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import RestrictedRouteMixin from 'gistr/mixins/restricted-route';


export default Ember.Route.extend(FormRouteMixin, RestrictedRouteMixin);
