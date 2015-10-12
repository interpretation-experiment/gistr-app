import Ember from 'ember';
import sample from 'gistr/utils/sample';

export default function shuffle(values) {
  if (Ember.isNone(values)) { return; }
  if (values.length === 0) { return []; }
  return sample(values, values.length);
}
