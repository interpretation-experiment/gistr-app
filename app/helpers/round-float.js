// Please note that Handlebars helpers will only be found automatically by the
// resolver if their name contains a dash (reverse-word, translate-text, etc.)
// For more details: http://stefanpenner.github.io/ember-app-kit/guides/using-modules.html

// FIXME: untested
export default Ember.Handlebars.makeBoundHelper(function(number, precision) {
  return Math.round(number * precision) / precision;
});

