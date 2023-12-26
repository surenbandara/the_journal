import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Firebase_auth {

  // Initialize a StreamController to handle the stream
  final StreamController<List<DocumentSnapshot>> _usersStreamController =
  StreamController<List<DocumentSnapshot>>.broadcast();

  Stream<List<DocumentSnapshot>> get usersStream =>
      _usersStreamController.stream;

  Future<void> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  Future<void> SignInWIthEmailProv() async {
    try {

      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      print("Sign In sucess!");
    } catch (error) {
      print("Error during sign-in: $error");

    }
  }

  Future<bool> addUsers(String selfemail , String selfname, String email , String name  ) async {

    List<Map<String, String>> billings = [];
    CollectionReference usersRefSender = FirebaseFirestore.instance.collection(selfemail);
    CollectionReference usersRefReciever = FirebaseFirestore.instance.collection(email);

    var querySnapshot = await usersRefReciever.where('email', isEqualTo: selfemail).get();
    if(querySnapshot.docs.isNotEmpty){
      var userDocument = querySnapshot.docs.first;
      var documentId = userDocument.id;

      var querySnapshot_self = await usersRefSender.where('email', isEqualTo: email).get();
      if(querySnapshot_self.docs.isNotEmpty){
        var userDocument_self = querySnapshot_self.docs.first;
        var documentId_self = userDocument_self.id;

        if(userDocument["request"]["recieve"]=="false"){
          await usersRefSender.doc(documentId_self).update({
            'request' : {
              'accept' : "true",
              'send' : "false" ,
              'recieve' : "false",
              'delete' : "false"
            }
          });

          await usersRefReciever.doc(documentId).update({
            'request' : {
              'accept' : "true",
              'send' : "false" ,
              'recieve' : "false",
              'delete' : "false"
            }
          });
        }

      }

      else{
        if(userDocument["request"]["recieve"]=="false"){
      await usersRefSender.add({
        'name': name,
        'email': email,
        'request' : {
          'accept' : "true",
          'send' : "false" ,
          'recieve' : "false",
          'delete' : "false"
        },
        'billings': billings
      });

        await usersRefReciever.doc(documentId).update({
          'request' : {
            'accept' : "true",
            'send' : "false" ,
            'recieve' : "false",
            'delete' : "false"
          }
        });}

        else{
          await usersRefSender.add({
            'name': name,
            'email': email,
            'request' : {
              'accept' : "false",
              'send' : "true" ,
              'recieve' : "false",
              'delete' : "false"
            },
            'billings': billings
          });
        }

      }



      return true;
    }

    else{

      var querySnapshot_self = await usersRefSender.where('email', isEqualTo: email).get();
      if(!querySnapshot_self.docs.isNotEmpty){
        await usersRefSender.add({
          'name': name,
          'email': email,
          'request' : {
            'accept' : "false",
            'send' : "true" ,
            'recieve' : "false",
            'delete' : "false"
          },
          'billings': billings
        });
      }



      await usersRefReciever.add({
        'name': selfname,
        'email': selfemail,
        'request' : {
          'accept' : "false",
          'send' : "false" ,
          'recieve' : "true",
          'delete' : "false"
        },
        'billings': billings
      });

      return false;
    }



  }

  Future<void> acceptRequest(String selfemail , String selfname , String email ,String name  ) async {

    var query = FirebaseFirestore.instance.collection(selfemail).where('email', isEqualTo: email);
    var querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      var userDocument = querySnapshot.docs.first;
      var documentId = userDocument.id;

      await FirebaseFirestore.instance.collection(selfemail).doc(documentId).update({
        'request' : {
          'accept' : "true",
          'send' : "false" ,
          'recieve' : "false",
          'delete' : "false"
        }
      });
    }

    query = FirebaseFirestore.instance.collection(email).where('email', isEqualTo: selfemail);
    querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      var userDocument = querySnapshot.docs.first;
      var documentId = userDocument.id;

      await FirebaseFirestore.instance.collection(email).doc(documentId).update({
        'request' : {
          'accept' : "true",
          'send' : "false" ,
          'recieve' : "false",
          'delete' : "false"
        }
      });
    }

  }


  Future<void> addBills(String selfemail , String email ,Map<String, String> bill  ) async {
    CollectionReference usersRef = FirebaseFirestore.instance.collection(selfemail);

    // Example: Query to retrieve a user document with a specific role
    var query = FirebaseFirestore.instance.collection(selfemail).where('email', isEqualTo: email);

    // Execute the query and get the documents
    var querySnapshot = await query.get();

    // Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming only one document is expected, you can access it using the first document
      var userDocument = querySnapshot.docs.first;

      // Access the document ID (if needed)
      var documentId = userDocument.id;

      // Access the data in the document
      var userData = userDocument.data();
      print(userData);
      userData['billings'].add(bill);

      // Example: Update the 'name' field of the user
      await FirebaseFirestore.instance.collection(selfemail).doc(documentId).update({
        'billings': userData['billings'],
      });
  }}


}
