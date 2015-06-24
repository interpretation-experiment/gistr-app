/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'gistr',
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
      API_NAMESPACE: 'api'
    },

    torii: {
      sessionServiceName: 'session',
      providers: {
        'spreadr': {}
      }
    },

    'ember-can': {
      inject: {
        session: 'torii:session'
      }
    }
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
    ENV.APP.API_HOST = '';

    ENV.APP.PROLIFIC_COMPLETION_URL = 'https://prolificacademic.co.uk/submissions/demo/complete?cc=NOCODE';
    ENV.APP.PROLIFIC_STUDY_URL = 'https://prolificacademic.co.uk/studies/demo';
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {
    // FIXME: API_HOST defaults to localhost:8000 if not told otherwise
    // (should default to window.location, but well...)
    // DEPLOY: set this
    ENV.APP.API_HOST = '//next.gistr.io';

    // DEPLOY: set this
    ENV.APP.PROLIFIC_COMPLETION_URL = 'https://prolificacademic.co.uk/submissions/demo/complete?cc=NOCODE';
    // DEPLOY: set this
    ENV.APP.PROLIFIC_STUDY_URL = 'https://prolificacademic.co.uk/studies/demo';
  }

  return ENV;
};
