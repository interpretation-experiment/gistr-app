import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import ProlificMixin from 'gistr/mixins/prolific';
import api from 'gistr/utils/api';


export default Ember.Route.extend(SessionMixin, ProfileRouteMixin, ProlificMixin, {
  model: function() {
    return Ember.RSVP.hash({
      stats: request(api('/stats/')),
      profileReadingSpan: this.get('currentProfile.readingSpan')
    });
  },
  setupController: function(controller, model) {
    if (Ember.isNone(model.profileReadingSpan)) { return; }

    var profileId = String(this.get('currentProfile.id')),
        profilesReadingTimes = model.stats.mean_read_time_proportion_per_profile,
        profilesWritingTimes = model.stats.mean_write_time_proportion_per_profile,
        profilesErrs = model.stats.mean_errs_per_profile;

    controller.setProperties({
      readingSpans: model.stats.profiles_reading_spans,
      profileReadingSpan: model.profileReadingSpan.get('span'),
      readingTimes: Object.keys(profilesReadingTimes).map(key => profilesReadingTimes[key]),
      writingTimes: Object.keys(profilesWritingTimes).map(key => profilesWritingTimes[key]),
      profileWritingTime: profilesWritingTimes[profileId],
      errs: Object.keys(profilesErrs).map(key => profilesErrs[key]),
      profileErr: profilesErrs[profileId]
    });
  }
});
