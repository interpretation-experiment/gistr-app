export default {
  name: 'controller-route-state',
  initialize: function(container, application) {
    application.inject('route', 'state', 'service:state');
    application.inject('controller', 'state', 'service:state');
  }
};
