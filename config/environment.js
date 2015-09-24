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
      API_NAMESPACE: 'api',

      // FIXME: workaround for https://github.com/ember-cli/ember-cli-deploy/issues/219
      CDN_PREPEND: '//d1zez0cfifq2rx.cloudfront.net/'
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

  if (environment === 'staging') {
    ENV.APP.API_HOST = '//next.gistr.io';

    // FIXME: workaround for https://github.com/ember-cli/ember-cli-deploy/issues/219
    ENV.APP.DO_CDN_FINGERPRINT = true;

    ENV.APP.PROLIFIC_COMPLETION_URL = 'https://prolificacademic.co.uk/submissions/demo/complete?cc=NOCODE';
    ENV.APP.PROLIFIC_STUDY_URL = 'https://prolificacademic.co.uk/studies/demo';
  }

  if (environment === 'production') {
    ENV.APP.API_HOST = '//gistr.io';

    // FIXME: workaround for https://github.com/ember-cli/ember-cli-deploy/issues/219
    ENV.APP.DO_CDN_FINGERPRINT = true;

    ENV.APP.PROLIFIC_COMPLETION_URL = 'https://prolificacademic.co.uk/submissions/551aa5c3fdf99b2c58162de9/complete?cc=COCBA68J';
    ENV.APP.PROLIFIC_STUDY_URL = 'https://prolificacademic.co.uk/studies/551aa5c3fdf99b2c58162de9';
  }

  return ENV;
};
