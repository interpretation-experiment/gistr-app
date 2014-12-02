// Start transition to play.ok and countdown
export default function(App) {
  var route = App.__container__.lookup('route:play/read'),
      controller = App.__container__.lookup('controller:play/read');
  route._startCountdown(controller);
}
