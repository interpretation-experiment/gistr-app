import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  // Pagination query parameters
  queryParams: ["page", "perPage"],

  // Pagination bindings
  pageBinding: "content.page",
  perPageBinding: "content.perPage",
  totalPagesBinding: "content.totalPages",

  // Pagination state variables
  page: 1,
  perPage: 10,
  perPageOptions: [5, 10, 25, 50, 100],
});
