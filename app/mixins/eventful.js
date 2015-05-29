import Ember from 'ember';


export default Ember.Mixin.create({
  log: function(text) {
    Ember.Logger.log('[eventful] ' + text);
  },

  init: function() {
    this._super.apply(this, arguments);

    this.log('init');
    // Make events specific to each mixin instance,
    // see note at http://emberjs.com/api/classes/Ember.Mixin.html
    this.set('events', Ember.A());

    this.setupObservers();
  },

  eventChecks: null,  // required
  eventFilter: null,  // required

  pushEvent: function(event) {
    this.log(`pushEvent '${event}'`);

    var events = this.get('events');
    if (!events.contains(event)) { events.push(event); }

    this.log(`events = ${events}`);
  },

  resetEvents: function() {
    this.log('resetEvents');

    this.set('events', []);
  },

  observedCache: {},
  observedChanged: function(sender, key) {
    this.log(`(observedChanged) ${key}`);

    //
    // Check change of the observed property
    //
    var observedCache = this.get('observedCache'),
        observed = key,
        observedNew = this.get(observed),
        wasCached = observed in observedCache,
        observedPrev = observedCache[observed];

    this.log(`(observedChanged) observedNew = ${observedNew}`);
    observedCache[observed] = observedNew;

    // Ignore this if it was the first time the property was set
    if (!wasCached) {
      this.log('(observedChanged) first set of observed => aborting');
      return;
    } else {
      this.log(`(observedChanged) observedPrev = ${observedPrev}`);
    }

    // Ignore this if there was no value change
    if (observedNew === observedPrev) {
      this.log('(observedChanged) observedNew === observedPrev => aborting');
      return;
    }

    // Get affected checks
    var self = this,
        eventChecks = this.get('eventChecks');

    var events = Object.keys(eventChecks).filter(function(eventName) {
      return (eventChecks[eventName].observes === observed &&
              self.eventFilter(eventName) &&
              Ember.run.bind(self, eventChecks[eventName].check)(observedPrev));
    });

    this.log(`(observedChanged) collected events = ${events}`);
    for (var event of events) { this.pushEvent(event); }
  },

  setupObservers: function() {
    this.log('setupObservers');

    var eventChecks = this.get('eventChecks'),
        observed;

    for (var eventName in eventChecks) {
      observed = eventChecks[eventName].observes;
      if (!Ember.isNone(observed)) {
        this.addObserver(observed, this, 'observedChanged');
      }
    }
  },
  removeObservers: function() {
    this.log('removeObservers');

    var eventChecks = this.get('eventChecks'),
        observed;

    for (var eventName in eventChecks) {
      observed = eventChecks[eventName].observes;
      if (!Ember.isNone(observed)) {
        this.removeObserver(observed, this, 'observedChanged');
      }
    }
  }
});
