App.presentation = App.cable.subscriptions.create("PresentationChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  select_page: function() {
    return this.perform('select_page');
  },

  send_emo: function() {
    return this.perform('send_emo');
  },

  send_comment: function() {
    return this.perform('send_comment');
  }
});
