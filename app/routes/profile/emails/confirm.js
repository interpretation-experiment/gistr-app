import Ember from 'ember';

import RestrictedRouteMixin from 'gistr/mixins/restricted-route';
import SessionMixin from 'gistr/mixins/session';


export default Ember.Route.extend(RestrictedRouteMixin, SessionMixin);