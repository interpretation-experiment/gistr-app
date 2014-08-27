import TracingRoute from 'appkit/routes/tracing-route';

export default TracingRoute.extend({
  authorizedOrigins: ['play.ok'],
  unauthorizedOriginRedirect: 'play.read',

  actions: {
    // No need to test this
    sendSentence: function() {
      this._sendSentence();
    }
  },

  _sendSentence: function() {
    // TODO[after backend]
    // sends the sentence
    // waits for answer
    // transitions to play/read
    // and test this
    console.log('sends the sentence');
    this.transitionTo('play.read');
  }
});
