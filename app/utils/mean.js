import Ember from 'ember';


export default function mean(array) {
  if (Ember.isNone(array)) { return; }
  if (array.length === 0) { return; }

  var sum = 0;
  for (var i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum / array.length;
}
