import Ember from 'ember';

import FormRouteMixin from './form-route';
import RestrictedRouteMixin from './restricted-route';


export default Ember.Route.extend(FormRouteMixin, RestrictedRouteMixin);
