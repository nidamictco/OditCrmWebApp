importScripts(
'https://www.gstatic.com/firebasejs/12.13.0/firebase-app-compat.js'
);

importScripts(
'https://www.gstatic.com/firebasejs/12.13.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
   apiKey: "AIzaSyCwYAM2Mai3kapSDCrIObEJjwvK5xJ2SMY",
   authDomain: "odit-crm.firebaseapp.com",
   projectId: "odit-crm",
   storageBucket: "odit-crm.firebasestorage.app",
   messagingSenderId: "71617127087",
   appId: "1:71617127087:web:f996a540618638bc6aaa5a",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {

 self.registration.showNotification(
   payload.notification?.title ?? "Notification",
   {
     body: payload.notification?.body ?? ""
   }
 );

});