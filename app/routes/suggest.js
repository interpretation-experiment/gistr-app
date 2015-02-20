import Ember from 'ember';
import RestrictedRouteMixin from './restricted';
import FormRouteMixin from './form';

export default Ember.Route.extend(RestrictedRouteMixin, FormRouteMixin);
