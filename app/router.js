var Router = Ember.Router.extend(); // ensure we don't share routes between all Router instances

Router.map(function() {
  this.route('component-test');
  this.route('helper-test');
  this.route('about');
  this.route('settings');
  this.resource('play', function() {
    this.route('read');
    this.route('ok');
    this.route('type');
  });
});

export default Router;
