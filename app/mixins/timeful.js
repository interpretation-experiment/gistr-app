import Ember from 'ember';

export default Ember.Mixin.create({
  /*
   * Parameters
   */
  duration: Ember.required(),
  precision: 100,  // updates per second

  /*
   * Callback
   */
  timerDone: Ember.required(),

  /*
   * Timing variables; progress is part of the public API
   */
  _lastNow: null,
  _time: null,
  _timer: null,
  _resetTimer: function() {
    this.setProperties({
      '_lastNow': null,
      '_time': null,
      '_timer': null,
    });
  },
  progress: function() {
    var offset = 100 / (this.get('duration') * this.get('precision'));
    return offset + 100 * this.get('_time') / this.get('duration');
  }.property('_time'),

  /*
   * Timing observers and triggerers
   */
  _timeChanged: function() {
    if (this.get('_time') >= this.get('duration')) {
      this.timerDone();
    }
  }.observes('_time'),
  _updateTime: function() {
    var now = Date.now(), diff = now - this.get('_lastNow');
    this.setProperties({
      '_lastNow': now,
      '_time': this.get('_time') + diff / 1000,
      '_timer': Ember.run.later(this, this._updateTime,
                                1000 / this.get('precision'))
    });
  },
  _startTime: function() {
    this.setProperties({
      '_lastNow': Date.now(),
      '_time': 0,
      '_timer': Ember.run.later(this, this._updateTime,
                                1000 / this.get('precision'))
    });
  }.on('didInsertElement'),
  _finishTime: function() {
    Ember.run.cancel(this.get('_timer'));
    this._resetTimer();
  }.on('willDestroyElement')
});
