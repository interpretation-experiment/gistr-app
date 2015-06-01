import Ember from 'ember';


export default Ember.Handlebars.makeBoundHelper(function(value/*, options*/) {
  if (Ember.isNone(value)) { return; }
  console.log(value);
  return value.capitalize();
});
