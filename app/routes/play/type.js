import TracingRoute from '../tracing-route';

export default TracingRoute.extend({
  authorizedOrigins: ['play.ok'],
  unauthorizedOriginRedirect: 'play.read'
});
