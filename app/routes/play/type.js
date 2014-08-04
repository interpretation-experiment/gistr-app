import TracingRoute from 'appkit/routes/tracing-route';

export default TracingRoute.extend({
  authorizedOrigins: ['play.ok'],
  unauthorizedOriginRedirect: 'play.read'
});
