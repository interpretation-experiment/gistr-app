import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import api from 'gistr/utils/api';


export default Ember.Route.extend(SessionMixin, ProfileRouteMixin, {
  model: function() {
    return Ember.RSVP.hash({
      stats: request(api('/stats/')),
      profileReadingSpan: this.get('currentProfile.readingSpan.span')
    });
  },
  setupController: function(controller, model) {
    var profileId = String(this.get('currentProfile.id')),
        profilesWritingTimes = model.stats.mean_time_proportion_per_profile,
        profilesErrs = model.stats.mean_errs_per_profile;

    controller.setProperties({
      readingSpans: model.stats.profiles_reading_spans,
      profileReadingSpan: model.profileReadingSpan,
      writingTimes: Object.keys(profilesWritingTimes).map(key => profilesWritingTimes[key]),
      profileWritingTime: profilesWritingTimes[profileId],
      errs: Object.keys(profilesErrs).map(key => profilesErrs[key]),
      profileErr: profilesErrs[profileId]
    });
  }
});
