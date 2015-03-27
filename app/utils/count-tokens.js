export default function countTokens(text) {
  return text.split(/[ |-|\n]+/).filter(function(item) {
    return item !== "";
  }).length;
}
