import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Mixin.create({
  prolificCompletionUrl: config.APP.PROLIFIC_COMPLETION_URL,
  prolificStudyUrl: config.APP.PROLIFIC_STUDY_URL,
});
