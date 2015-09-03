import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('login', function() {
    this.route('lost');
    this.route('reset');
  });
  this.route('register');
  this.route('prolific');
  this.route('about');
  this.route('profile', function() {
    this.route('profile', function() {
      this.route('questionnaire');
      this.route('word-span');
    });
    this.route('admin');
    this.route('emails', function() {
      this.route('confirm');
    });
  });
  this.route('play');
  this.route('suggest');
  this.route('explore', function() {
    this.route('tree', { path: '/:tree_id' });
  });
  this.route('reports');

  // Why there needs to be the "wildcard" text after the "*"
  // (it can be any other text in fact), beats me.
  this.route('catchall', {path: '/*wildcard'});
});

export default Router;
