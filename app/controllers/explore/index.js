import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Pagination query parameters
   */
  queryParams: ["page", "perPage", "root_bucket"],

  /*
   * Pagination bindings
   */
  pageBinding: "content.page",
  perPageBinding: "content.perPage",
  totalPagesBinding: "content.totalPages",

  /*
   * Pagination state variables
   */
  page: 1,
  perPage: 10,
  perPageOptions: [5, 10, 25, 50, 100],

  pageLoad: function() {
    var self = this;
    this.send('loading');
    this.get('content.promise').finally(function() {
      self.send('finished');
    });
  }.observes('content.promise'),

  /*
   * Bucket selection
   */
  root_bucket: 'experiment',
  buckets: function() {
    var staff = this.get('currentUser.isStaff');
    return this.get('lifecycle.buckets').filter(function(bucket) {
      return staff || (bucket.name !== 'training');
    });
  }.property(),
  bucketResetPage: function() {
    this.set('page', 1);
  }.observes('root_bucket')
});
