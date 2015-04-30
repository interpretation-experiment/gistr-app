export default {
  name: 'component-service-session',
  initialize: function(container, application) {
    application.inject('component', 'session', 'torii:session');
    application.inject('service', 'session', 'torii:session');
  }
};
