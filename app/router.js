import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login');
  this.route('register');
  this.route('about');
  this.route('settings');
  this.route('play');
  this.route('suggest');
  // Why there needs to be the "wildcard" text after the "*"
  // (it can be any other text in fact), beats me.
  this.route('catchall', {path: '/*wildcard'});
});

export default Router;
