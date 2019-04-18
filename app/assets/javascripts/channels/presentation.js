App.presentation = App.cable.subscriptions.create("PresentationChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
    console.log("connected");
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
    console.log("disconnected");
  },

  // Send Ovto action call to the channel
  send_action: function(name, kwargs) {
    return this.perform('send_action', {ovto_action: name, kwargs: kwargs});
  },

  received: function(data) {
    //console.log("received", data);
    if (data['action'] == 'send_action') {
      // Perform Ovto action sent to the channel
      var action_name = data['ovto_action'];
      var args_hash = Opal.hash(data['kwargs']);
      Opal.OvtoApp.$instance().$actions().$send("invoke_action", action_name, args_hash);
    }
  },

});
