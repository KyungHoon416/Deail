const express = require("express");
const app = express();
const admin = require("firebase-admin");

const serviceAccount = require("./daeiliosapp-firebase-admins-fdbd580abb.json");

app.use(express.json()); // JSON ???

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

app.post("/send-push", async (req, res) => {
  console.log("headers:", req.headers);
  console.log("body(raw):", req.body);

  const { tokens, notification, data } = req.body;

  if (!tokens || !notification || !notification.title || !notification.body) {
    return res.status(400).json({ success: false, error: "??? ??? ??????" });
  }

  const message = {
    tokens: Array.isArray(tokens) ? tokens : [tokens],
    notification: {
      title: notification.title,
      body: notification.body,
    //   image: notification.image || undefined // Android??
    },
    data: Object.fromEntries(
        Object.entries({
          ...data,
          imageURL: data?.imageURL || "",
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        }).map(([key, val]) => [key, String(val ?? "")])
      ),
      android: { //??????? ?????
        priority: "high",
        notification: {
            title: notification.title,
            body: notification.body,
            // image: notification.image ?? null,
            sound: "default",
            visibility: "public", // ? ??? ???????? ????
            defaultSound: true,
            channelId: "Daeil_Channel_v3" // ? ???? ?????? ??? ??? ID
          }
      },
    apns: {
        headers: {
          "apns-priority": "10"
        },
        payload: {
          aps: {
            "mutable-content": 1,
            "content-available": 1,
            sound: "default"
          }
        },
      fcm_options: {
        // image: notification.image || undefined
      }
    }
  };


  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    const successCount = response.successCount;
    const failureCount = response.failureCount;
    const responses = response.responses; 
    const fullMessageId = responses.message
    console.log("FCM ???? response:", JSON.stringify(response, null, 2));
    console.log("Android ????? ????:", JSON.stringify(message.android, null, 2));
    res.json({
        success: true,
        successCount,
        failureCount,
        details: responses
      });
  } catch (err) {
    console.error("? FCM ???? ????:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

const os = require("os");

function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

app.listen(3000, "0.0.0.0", () => {
    const ip = getLocalIP();
    console.log(`Server running at: http://${ip}:3000`);
  });


app.get("/", (req, res) => {
    
    res.send("FCM Push Server is running!");
});

