/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyUsersOnNewProduct = functions.database
    .ref("/Products/{productId}")
    .onCreate(async (snapshot, context) => {
        try {
            const userList = await admin.auth().listUsers();
            const notificationPayload = {
                notification: {
                    title: "New Product Added!",
                    body: "Check out our latest product!",
                },
            };

            const notificationPromises = userList.users.map(user =>
                admin.messaging().sendToDevice(user.uid, notificationPayload)
            );

            await Promise.all(notificationPromises);
            console.log("Notifications sent to all authenticated users.");
        } catch (error) {
            console.error("Error sending notifications:", error);
        }
    });

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
