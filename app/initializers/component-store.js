export default {
  name: 'component-store',
  initialize: function(container, application) {
    application.inject('component', 'store', 'store:main');
  }
};
