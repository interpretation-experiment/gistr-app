export default {
  name: 'torii-adapter-store',
  initialize: function(container, application) {
    application.inject('torii-adapter', 'store', 'store:main');
  }
};
