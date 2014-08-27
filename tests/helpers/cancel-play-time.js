// Cancel transition to play.ok and countdown
export default function(App) {
  var route = App.__container__.lookup('route:play/read');
  route.set('startCountdown', false);
}
