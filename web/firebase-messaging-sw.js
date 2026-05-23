importScripts(
'https://www.gstatic.com/firebasejs/12.13.0/firebase-app-compat.js'
);

importScripts(
'https://www.gstatic.com/firebasejs/12.13.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
 apiKey: "AIzaSyAb1qg3coXeIhrLAFDbpvqZMTygQPM5GvY",
 authDomain: "oxdo-leads.firebaseapp.com",
 projectId: "oxdo-leads",
 storageBucket: "oxdo-leads.firebasestorage.app",
 messagingSenderId: "446854947362",
 appId: "1:446854947362:web:e03b0758ab7b15ea64e07b"
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