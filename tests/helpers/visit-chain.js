// Walk through pages and check you end up in the right place
export default function(pages, arrival) {
  for (var i = 0; i < pages.length; i++) {
    visit(pages[i]);
  }

  if (!!arrival) {
    andThen(function() {
      equal(currentRouteName(), arrival);
    });
  }
}
