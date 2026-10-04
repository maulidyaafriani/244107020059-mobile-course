importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyBna3QDMRiEMLxTG4g0fG4caZXEegu9IZs',
  authDomain: 'campus-notify-db837.firebaseapp.com',
  projectId: 'campus-notify-db837',
  storageBucket: 'campus-notify-db837.firebasestorage.app',
  messagingSenderId: '214757259024',
  appId: '1:214757259024:web:7af9669e364a7b799f1795',
});

firebase.messaging();
