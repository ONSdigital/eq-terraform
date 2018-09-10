var AWS = require("aws-sdk");
var https = require("https");

function is500Error(alertState) {

    if (alertState["Trigger"]) {
        var trigger = alertState["Trigger"];

        return trigger["MetricName"] === "HTTPCode_Target_5XX_Count";
    }

    return false;
}

function sendSlackAlert(context, alertState, errorMessage, link) {

    console.log("Sending alert to Slack Channel: #" + process.env.slack_channel);

    var options = {
        hostname: 'hooks.slack.com',
        port: 443,
        path: process.env.slack_webhook_path,
        method: 'POST'
    };

    var payload =
        {
            "channel": "#" + process.env.slack_channel,
            "attachments": [
                {
                    "title": alertState.NewStateReason,
                    "pretext": alertState.AlarmDescription,
                    "color": "#FF0000",
                    "fields": [
                        {
                            "title": "Alarm",
                            "value": alertState.AlarmName,
                            "short": true
                        },
                        {
                            "title": "StateChangeTime",
                            "value": alertState.StateChangeTime,
                            "short": true
                        }
                    ]
                }]
        };

    if (errorMessage !== "") {

        payload.attachments.push({
            "title": "Error Message",
            "text": errorMessage
        });
    }
    if (link !== "") {
        payload.attachments.push({
            "fallback": "View log message at " + link,
            "actions": [
                {
                    "type": "button",
                    "text": "View Log Message",
                    "url": link
                }
            ]
        });
    }

    var req = https.request(options, function (res) {
        res.on("data", function () {
            console.log("Successfully sent alert to Slack Channel: #" + process.env.slack_channel);
            context.done(null, 'done!');
        });
    }).on('error', function (e) {
        console.log("Failed sending alert to Slack Channel: #" + process.env.slack_channel);
        console.error(e);
        context.done('error', e);
    });
    req.write(JSON.stringify(payload));
    req.end();

}

exports.handler = function (event, context) {

    console.log("event", event);
    console.log("sns", event.Records[0].Sns);

    var alertState = JSON.parse(event.Records[0].Sns.Message);
    var message = "";
    var link = "";

    if (is500Error(alertState)) {

        var dimensions = alertState["Trigger"]["Dimensions"];

        var logGroup = "";

        for (var i = 0; i < dimensions.length; i++) {
            var dimension = dimensions[i];
            if (dimension["name"] === "TargetGroup") {
                logGroup = dimension["value"].split("/")[1];
                break;
            }
        }

        if (logGroup !== "") {

            var cloudwatchlogs = new AWS.CloudWatchLogs();

            var params = {
                logGroupName: logGroup, /* required */
                endTime: Date.now(),
                filterPattern: "{$.status_code=500}",
                interleaved: true,
                startTime: (Date.now() - 1000 * 60 * 15) /* now minus 5 mins */
            };
            cloudwatchlogs.filterLogEvents(params, function (err, data) {
                if (err) {
                    console.log(err, err.stack); // an error occurred
                } else {
                    console.log(data);           // successful response
                }

                var events = data["events"];


                if (events != null && events.length > 0) {
                    message = JSON.stringify(JSON.parse(events[0].message), null, 2);

                    link = "https://eu-west-1.console.aws.amazon.com/cloudwatch/home?" +
                        "region=eu-west-1" +  /* region */
                        "#logEventViewer:group=" + logGroup +
                    ";stream=" + events[0].logStreamName +
                    ";refid=" + events[0].eventId +
                    ";reftime=" + events[0].timestamp + ";";
                }


                sendSlackAlert(context, alertState, message, link);
            });
        } else {
            sendSlackAlert(context, alertState, message, link);
        }
    } else {
        sendSlackAlert(context, alertState, message, link);
    }
};