var https = require( 'https' );
exports.handler = function(event, context){
    var options = {
        hostname: 'hooks.slack.com',
        port: 443,
        path: process.env.slack_webhook_path,
        method: 'POST'
     };

     var isSns = !!event.Records;
     var alertState, preText, fallbackMsg, title, value;
     if (isSns) {
         alertState = JSON.parse(event.Records[0].Sns.Message);
         preText = alertState.AlarmDescription;
         fallbackMsg = alertState.AlarmDescription + ": " + alertState.NewStateReason,
         title = alertState.AlarmDescription;
         value = alertState.NewStateReason;
     } else {
         alertState = event.detail.state;
         preText = process.env.env_var + " " + event['detail-type'];
         fallbackMsg = process.env.env_var + " " + event['detail-type'] + ": " + event.detail.state + " (" + event.detail['instance-id'] + ")";
         title = event.detail.state;
         value = event.detail['instance-id'];
     }

     console.log("Sending alert to Slack Channel: #" + process.env.slack_channel);

     var payload = JSON.stringify(
         {
            "channel": "#" + process.env.slack_channel,
            "attachments": [{
                "fallback": fallbackMsg,
                "text" : "",
                "pretext" : preText,
                "color": "#FF0000",
	            "fields": [{
		            "title": title,
		            "value": value,
		            "short": false
		        }]
            }]
        });

    var req = https.request(options, function(res) {
        res.on("data", function() {
            console.log("Successfully sent alert to Slack Channel: #" + process.env.slack_channel);
            context.done(null, 'done!');
        });
    }).on('error', function(e) {
        console.log("Failed sending alert to Slack Channel: #" + process.env.slack_channel);
        console.error(e);
        context.done('error', e);
    });
    req.write(payload);
    req.end();
};