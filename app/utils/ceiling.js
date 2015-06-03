export default function ceiling(number, precision=1) {
  return Math.ceil(number * precision) / precision;
}
