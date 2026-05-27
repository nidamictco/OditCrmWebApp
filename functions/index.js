const functions = require("firebase-functions");
const axios = require("axios");

const MSG91_AUTH_KEY = "519691AZHrE9FNxa6a13e653P1";
const MSG91_TEMPLATE_ID = "6a13e45ea8e4a0aeaf0a5442";

// ─── Send OTP ────────────────────────────────────────────────────────────────
// exports.sendOtp = functions.https.onCall(async (data, context) => {
//   const mobile = data.mobile?.toString().trim();

//   if (!mobile || mobile.length < 10) {
//     throw new functions.https.HttpsError("invalid-argument", "Invalid mobile number.");
//   }

//   const formatted = mobile.startsWith("91") ? mobile : `91${mobile}`;

//   try {
//     const response = await axios.post(
//       "https://control.msg91.com/api/v5/otp",
//       {
//         mobile: formatted,
//         template_id: MSG91_TEMPLATE_ID,
//         sender: "OXDOTP",
//         otp_length: 6,
//         otp_expiry: 10,
//       },
//       {
//         headers: {
//           "Content-Type": "application/json",
//           authkey: MSG91_AUTH_KEY,
//         },
//       }
//     );

//     if (response.data?.type === "error") {
//       throw new functions.https.HttpsError("internal", response.data.message);
//     }

//     return { success: true };
//   } catch (e) {
//   console.error("MSG91 ERROR:", e.response?.data || e);

//   throw new functions.https.HttpsError(
//     "internal",
//     e.response?.data?.message ||
//     e.message ||
//     "Failed to send OTP"
//   );
// }
// });
exports.sendOtp = functions
  .region("asia-south1")
  .https.onCall(async (data, context) => {

    const mobile = data.mobile?.toString().trim();

    console.log("Received mobile:", mobile);

    if (!mobile || mobile.length < 10) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid mobile number."
      );
    }

    const formatted = mobile.startsWith("91")
      ? mobile
      : `91${mobile}`;

    try {

      const response = await axios.post(
        "https://control.msg91.com/api/v5/otp",
        {
          mobile: formatted,
          template_id: MSG91_TEMPLATE_ID,
          sender: "OXDOTP",
          otp_length: 6,
          otp_expiry: 10,
        },
        {
          headers: {
            authkey: MSG91_AUTH_KEY,
            "Content-Type": "application/json",
          },
        }
      );

      console.log("MSG91 RESPONSE:", response.data);

      return {
        success: true,
        data: response.data,
      };

    } catch (e) {

      console.error(
        "FULL ERROR:",
        e.response?.data || e.message || e
      );

      throw new functions.https.HttpsError(
        "internal",
        JSON.stringify(e.response?.data || e.message)
      );
    }
  });

// ─── Verify OTP ──────────────────────────────────────────────────────────────
exports.verifyOtp = functions.https.onCall(async (data, context) => {
  const mobile = data.mobile?.toString().trim();
  const otp = data.otp?.toString().trim();

  if (!mobile || !otp) {
    throw new functions.https.HttpsError("invalid-argument", "Mobile and OTP required.");
  }

  const formatted = mobile.startsWith("91") ? mobile : `91${mobile}`;

  try {
    const response = await axios.get(
      `https://control.msg91.com/api/v5/otp/verify?mobile=${formatted}&otp=${otp}`,
      {
        headers: { authkey: MSG91_AUTH_KEY },
      }
    );

    if (response.data?.type === "error") {
      throw new functions.https.HttpsError("internal", response.data.message);
    }

    return { success: true };
  } catch (e) {
  console.error("MSG91 ERROR:", e.response?.data || e);

  throw new functions.https.HttpsError(
    "internal",
    e.response?.data?.message ||
    e.message ||
    "Failed to send OTP"
  );
}
});

// ─── Resend OTP ───────────────────────────────────────────────────────────────
exports.resendOtp = functions.https.onCall(async (data, context) => {
  const mobile = data.mobile?.toString().trim();

  if (!mobile) {
    throw new functions.https.HttpsError("invalid-argument", "Mobile required.");
  }

  const formatted = mobile.startsWith("91") ? mobile : `91${mobile}`;

  try {
    const response = await axios.get(
      `https://control.msg91.com/api/v5/otp/retry?mobile=${formatted}&retrytype=text`,
      {
        headers: { authkey: MSG91_AUTH_KEY },
      }
    );

    if (response.data?.type === "error") {
      throw new functions.https.HttpsError("internal", response.data.message);
    }

    return { success: true };
  } catch (e) {
  console.error("MSG91 ERROR:", e.response?.data || e);

  throw new functions.https.HttpsError(
    "internal",
    e.response?.data?.message ||
    e.message ||
    "Failed to send OTP"
  );
}
});