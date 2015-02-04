export default function draw(array) {
  var index = Math.floor(Math.random() * array.get('length'));
  return array.objectAt(index);
}
