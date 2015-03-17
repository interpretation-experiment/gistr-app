export default {
  name: 'component-session',
  initialize: function(container, application) {
    application.inject('component', 'session', 'torii:session');
  }
};
