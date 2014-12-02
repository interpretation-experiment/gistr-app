import TracingRoute from '../tracing-route';

export default TracingRoute.extend({
  authorizedOrigins: ['play.read'],
  unauthorizedOriginRedirect: 'play.read'
});
