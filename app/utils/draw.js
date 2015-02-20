import randint from './randint';

export default function draw(array) {
  var index = randint(array.get('length'));
  return array.objectAt(index);
}
