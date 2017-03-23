var https = require( 'https' );
exports.handler = function(event, context){
    
    var options = {
        hostname: 'hooks.slack.com',
        port: 443,
        path: process.env.slack_webhook_path,
        method: 'POST'
     };

     var alertState = JSON.parse(event.Records[0].Sns.Message);

     console.log("Sending alert to Slack Channel: #eq-" + process.env.environment_name + "-alerts");

     var payload = JSON.stringify(
         {
            "channel": "#eq-" + process.env.environment_name + "-alerts",
            "attachments": [{   
                "fallback": alertState.AlarmDescription + ": " + alertState.NewStateReason,
                "text" : "",
                "pretext" : alertState.AlarmName,
                "color": "#FF0000",
	            "fields": [{
		            "title": alertState.AlarmDescription,
		            "value": alertState.NewStateReason,
		            "short": false	
		        }]
            }]
        });
    
    var req = https.request(options, function(res) {
        res.on("data", function() {
            console.log("Successfully sent alert to Slack Channel: #eq-" + process.env.environment_name + "-alerts");
            context.done(null, 'done!');
        });
    }).on('error', function(e) {
        console.log("Failed sending alert to Slack Channel: #eq-" + process.env.environment_name + "-alerts");
        console.error(e);
        context.done('error', e);
    });
    req.write(payload);
    req.end();
};