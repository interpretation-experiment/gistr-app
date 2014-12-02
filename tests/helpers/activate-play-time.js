// Activate transition to play.ok and countdown
export default function(App, active, duration, precision) {
  var route = App.__container__.lookup('route:play/read'),
      controller = App.__container__.lookup('controller:play/read');
  route.set('startCountdown', active);

  if (!!duration) {
    controller.set('duration', duration);
  }
  if (!!precision) {
    controller.set('precision', precision);
  }
}
