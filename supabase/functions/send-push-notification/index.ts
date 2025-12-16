// File: supabase/functions/send-push-notification/index.ts

import { serve } from "https://deno.land/std@0.131.0/http/server.ts";

serve(async (req) => {
  try {
    const { record } = await req.json();

    // Extract notification data from "notifications" table
    const fcmToken = record.fcm_token;
    const title = record.title;
    const body = record.body;
    const data = record.data ?? {};

    if (!fcmToken) {
      return new Response("Missing FCM token", { status: 400 });
    }

    // FCM Server Key (store in Supabase Project → Settings → Functions → Secrets)
    const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY");
    if (!FCM_SERVER_KEY) {
      return new Response("FCM server key not found", { status: 500 });
    }

    // FCM API URL
    const url = "https://fcm.googleapis.com/fcm/send";

    // Payload to send
    const payload = {
      to: fcmToken,
      notification: {
        title,
        body,
      },
      data, // Optional extra payload
    };

    // Send to FCM
    const result = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": `key=${FCM_SERVER_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const responseText = await result.text();

    return new Response(
      JSON.stringify({ message: "Sent", fcmResponse: responseText }),
      { status: 200 }
    );

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
});
