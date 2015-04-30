export default {
  name: 'controller-route-lifecycle',
  initialize: function(container, application) {
    application.inject('route', 'lifecycle', 'service:lifecycle');
    application.inject('controller', 'lifecycle', 'service:lifecycle');
  }
};
