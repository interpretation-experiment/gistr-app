import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('about');
  this.route('settings');
  this.resource('play', function() {
    this.route('read');
    this.route('ok');
    this.route('type');
  });
});

export default Router;
