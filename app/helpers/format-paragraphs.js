import Ember from 'ember';


export default Ember.Handlebars.makeBoundHelper(function(value/*, options*/) {
  if (Ember.isNone(value)) { return; }
  let escaped = Ember.Handlebars.Utils.escapeExpression(value);
  return Ember.String.htmlSafe('<p>' + escaped.split(/\n\n/).join('</p><p>') + '</p>');
});
