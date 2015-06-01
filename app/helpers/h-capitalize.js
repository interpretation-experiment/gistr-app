import Ember from 'ember';


export default Ember.Handlebars.makeBoundHelper(function(value/*, options*/) {
  if (Ember.isNone(value)) { return; }
  return value.capitalize();
});
