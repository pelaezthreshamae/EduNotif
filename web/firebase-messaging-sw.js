importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "YOUR KEY",
  authDomain: "YOUR",
  projectId: "YOUR",
  messagingSenderId: "YOUR",
  appId: "YOUR"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  self.registration.showNotification(message.notification.title, {
    body: message.notification.body,
  });
});
