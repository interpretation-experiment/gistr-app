var separator = /:/;
export default function splitEvent(event) {
  var parts = event.split(separator);
  return {
    state: parts[0],
    type: parts[1],
    name:parts[2]
  };
}
