import Ember from 'ember';
import { request } from 'ic-ajax';

import api from 'gistr/utils/api';


export default Ember.Object.extend({
  open: function(credentials) {
    return request(api('/rest-auth/login/'), {
      type: 'POST',
      data: { username: credentials.username, password: credentials.password }
    }).then(null, function(errors) {
      return errors.jqXHR.responseJSON || { non_field_errors: errors.errorThrown };
    });
  }
});
