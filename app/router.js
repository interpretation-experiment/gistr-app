import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login');
  this.route('register');
  this.route('about');
  this.route('profile');
  this.route('play');
  this.route('suggest');
  this.route('explore', function() {
    this.route('tree', { path: '/:tree_id' });
  });

  // Why there needs to be the "wildcard" text after the "*"
  // (it can be any other text in fact), beats me.
  this.route('catchall', {path: '/*wildcard'});
});

export default Router;
