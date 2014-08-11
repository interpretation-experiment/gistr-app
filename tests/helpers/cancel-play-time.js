// Cancel transition to play.ok and countdown
export default function(App) {
  var prController = App.__container__.lookup('controller:play/read');

  prController.addObserver('transitionTimer', function() {
    Ember.run.cancel(prController.get('transitionTimer'));
  });
  prController._reschedule = function() {};
}
