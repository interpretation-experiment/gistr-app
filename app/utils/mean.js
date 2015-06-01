import Ember from 'ember';


export default function mean(array) {
  if (Ember.isNone(array)) { return; }
  if (array.length === 0) { return; }

  var sum = 0;
  for (var value of array) {
    sum += value;
  }
  return sum / array.length;
}
