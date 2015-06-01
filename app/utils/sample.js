import Ember from 'ember';
import randint from 'gistr/utils/randint';

export default function sample(values, number) {
  if (Ember.isNone(values)) { return; }
  if (Ember.isNone(number)) { return; }
  if (values.length < number) {
    throw new Error("Can't sample more than available values");
  }

  var remainingValues = Ember.copy(values),
      sampled = [];
  for (var i = 0; i < number; i++) {
    sampled.push(remainingValues[randint(remainingValues.length)]);
    remainingValues.removeAt(i);
  }

  return sampled;
}
