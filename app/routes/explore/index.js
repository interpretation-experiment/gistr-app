import Ember from 'ember';

import PaginationRouteMixin from 'ember-cli-pagination/remote/route-mixin';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';
import ceiling from 'gistr/utils/ceiling';


export default Ember.Route.extend(SessionMixin, FormRouteMixin, PaginationRouteMixin, {
  queryParams: {
    root_bucket: { refreshModel: true }
  },
  model: function(params) {
    params.paramMapping = {
      page: 'page',
      perPage: 'page_size',
      total_pages: [
        'count',
        function({rawVal, page, perPage}) {
          if (Ember.isNone(perPage) || perPage === 0) { return rawVal; }
          return ceiling(rawVal / perPage);
        }
      ]
    };
    // Restrict to own trees if not staff
    if (!this.get('currentUser.isStaff')) {
      params.profile = this.get('currentProfile.id');
    }
    return this.findPaged('tree', params);
  }
});
