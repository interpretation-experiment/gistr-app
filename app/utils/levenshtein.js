var cache = {},
    levenshtein = function(a, b) {
  // From https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#JavaScript
  if(a.length === 0) { return b.length; }
  if(b.length === 0) { return a.length; }

  var matrix = [];

  // Increment along the first column of each row
  var i;
  for(i = 0; i <= b.length; i++){
    matrix[i] = [i];
  }

  // Increment each column in the first row
  var j;
  for(j = 0; j <= a.length; j++){
    matrix[0][j] = j;
  }

  // Fill in the rest of the matrix
  for(i = 1; i <= b.length; i++){
    for(j = 1; j <= a.length; j++){
      if(b.charAt(i-1) === a.charAt(j-1)){
        matrix[i][j] = matrix[i-1][j-1];
      } else {
        matrix[i][j] = Math.min(matrix[i-1][j-1] + 1, // substitution
                                Math.min(matrix[i][j-1] + 1, // insertion
                                         matrix[i-1][j] + 1)); // deletion
      }
    }
  }

  return matrix[b.length][a.length];
};

export default function(a, b) {
  if (!((a in cache) && (b in cache[a]))) {
    // Distance not in cache, compute it
    if (!(a in cache)) { cache[a] = {}; }
    if (!(b in cache)) { cache[b] = {}; }
    var d = levenshtein(a, b);
    cache[a][b] = d;
    cache[b][a] = d;
  }

  return cache[a][b];
}
