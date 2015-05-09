import Ember from 'ember';

// See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/includes
export default {
  name: 'polyfill-string-includes',
  initialize: function() {
    if (!String.prototype.includes) {
      String.prototype.includes = function() {'use strict';
        return String.prototype.indexOf.apply(this, arguments) !== -1;
      };
    }
  }
};
