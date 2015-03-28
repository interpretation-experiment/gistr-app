import Ember from 'ember';


export default function(a, b) {
  var parents = function(node) {
    if (node.parent) {
      var upper = parents(node.parent);
      upper.push(node);
      return upper;
    } else {
      return [node];
    }
  };

  var parentsA = parents(a),
      parentsB = parents(b);

  // Are we in direct filiation?
  if (parentsA.contains(b)) { return parentsA.slice(parentsA.indexOf(b)).reverse(); }
  if (parentsB.contains(a)) { return parentsB.slice(parentsB.indexOf(a)); }

  // We may be cousins: find the last common ancestor
  var ancestor = null;
  parentsA.forEach(function(parent) {
    if (parentsB.contains(parent)) { ancestor = parent; }
  });

  if (Ember.isNone(ancestor)) {
    return [];
  } else {
    var iA = parentsA.indexOf(ancestor), iB = parentsB.indexOf(ancestor);
    return parentsA.slice(iA).reverse().pushObjects(parentsB.slice(iB + 1));
  }
}
