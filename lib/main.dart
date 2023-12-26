import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled6/sign_in.dart';
import 'billing.dart';
import 'firbase/firbase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Firebase_auth firebaseAuth = Firebase_auth();

  // Using then:

  // Check if a user is already signed in
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    firebaseAuth.SignInWIthEmailProv().then((resultUser) {
      runApp(const MyApp());
      FlutterNativeSplash.remove();

    });
  } else {
    runApp(const MyApp());
    FlutterNativeSplash.remove();
  }

}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Journal',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "The Journal" ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title });


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  var requests = [];
  Map<String, dynamic> tickets = {"loading" : true , "tickets" : []};

  @override
  void initState() {
    super.initState();
    _refreshWidget();
  }

  Future<void> initializeTickets() async {
    try {
      tickets["loading"] = true;
      tickets["tickets"] = [];
      requests = [];
      setState(() {
      });

      // Replace 'your_self_email' with the actual email you want to use
      String selfEmail =  FirebaseAuth.instance.currentUser?.email ?? "Unknown";


      // Create a reference to the 'users' collection
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(selfEmail);

      // Get the documents in the collection
      QuerySnapshot querySnapshot = await usersCollection.get();

      // Iterate through the documents and access the data
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

        // Access individual fields from the document
        String userName = data['name'];
        String userEmail = data['email'];
        String isSelfSender = data['request']['send'];
        String isSelfReciver = data['request']['recieve'];
        String isAccepted = data['request']['accept'];
        String isDeleted = data['request']['delete'];


        if (isSelfReciver == "true"){
          requests.add({'name': userName, 'email': userEmail  ,
            'request' : {
              'accept' : isAccepted,
              'send' : isSelfSender ,
              'recieve' : isSelfReciver,
              'delete' : isDeleted
            }});
        }

        else{
          tickets["tickets"].add({'name': userName, 'email': userEmail ,
            'request' : {
              'accept' : isAccepted,
              'send' : isSelfSender ,
              'recieve' : isSelfReciver,
              'delete' : isDeleted
            }});
        }


      }

      // Update the state to trigger a rebuild with the fetched data

    } catch (e) {
      print('Error initializing tickets: $e');
    }
  }

  void _refreshWidget() {
      initializeTickets().then((value){
        tickets["loading"] =false;
        setState(() {});
      });
  }

  Widget getRequestIcon(String isAccepted, String isSelfSender , String isSelfReciver ,String isDeleted) {
    if (isAccepted == "true") {
      return const Icon(
        Icons.check_circle,
        size: 15,
        color: Colors.green,
      );
    } else {
      if (isDeleted == "true"){
        return const Icon(
          Icons.no_accounts_rounded,
          size: 15,
          color: Colors.amber,
        );

    }
      else {
        return const Icon(
          Icons.pending_actions,
          size: 15,
          color: Colors.white,
        );
      }
      }
  }

  @override
  Widget build(BuildContext context) {
    if( FirebaseAuth.instance.currentUser == null){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Image.asset(
            'assest/splash_image.png',
            height: 30, // Adjust the width based on your ratio
            fit: BoxFit.cover,
          ),

        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Sign in to stay with The Journal !"
                ,style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ), ),
              SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.indigo),
                onPressed: () {
                  Firebase_auth firebaseAuth = Firebase_auth();
                  firebaseAuth.SignInWIthEmailProv().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "The Journal")),
                    );
                  });
                },
                child: const Text('Sign In' ,
                  style: TextStyle(
                    color: Colors.white,

                  ),),
              ),
            ],
          ),
        ),
      );
    }else{

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Image.asset(
          'assest/splash_image.png',
          height: 30, // Adjust the width based on your ratio
          fit: BoxFit.cover,
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Implement the refresh logic here
              _refreshWidget();
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
            children: [
              GestureDetector(
              onTap: () {

                _showPopup(context);
            },
            child: const Icon(
              Icons.add_alert_outlined, // Use the desired profile icon
            )
            ),
            requests.isNotEmpty? Positioned(
            right: 0,
            child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
            color: Colors.red, // Set your desired badge color
            shape: BoxShape.circle,
            ),
            child: Text(
            requests.length.toString(),
            style: const TextStyle(color: Colors.white ,
            fontSize: 12 ),
            ),
            ),
            ) : SizedBox.shrink()] ) ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showOptions(context);
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser?.photoURL ?? "Unknown",
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),

        body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust the top and bottom padding as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  child :
                    tickets["loading"]
                        ? const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black, // Set the color of the bubbles
                        size: 50.0, // Set the size of the spinner
                      ),
                    ) :
                    tickets["tickets"].isEmpty
                        ? const Center(
                      child: Text(
                        'No Friends',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ):
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: tickets["tickets"].length,
                      itemBuilder: (context, index) {
                        String name = tickets["tickets"][index]['name'] ?? '';
                        String email = tickets["tickets"][index]['email'] ?? '';
                        String total = tickets["tickets"][index]['total'] ?? '';
                        String isSelfSender = tickets["tickets"][index]['request']['send'];
                        String isSelfReciver = tickets["tickets"][index]['request']['recieve'];
                        String isAccepted = tickets["tickets"][index]['request']['accept'];
                        String isDeleted = tickets["tickets"][index]['request']['delete'];

                        return InkWell(
                          onTap: () async {

                            var newData = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BillingStatefulWidget(title: "The Journal", email: email, name: name )),
                            );
                            // Check if newData is not null, and refresh the page
                            print(newData);
                            if (newData != null) {
                              tickets["loading"] = true;
                              _refreshWidget();
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            color: Colors.blueGrey, // Change the color as needed
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.account_circle, // Use the desired profile icon
                                    size: 32, // Set the size of the icon as needed
                                    color: Colors.white, // Set the color of the icon
                                  ),

                                  getRequestIcon(isAccepted ,isSelfSender , isSelfReciver ,isDeleted),



                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                )
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          _showEditor(context);
        },
        label: const Text(
          "Add User",
          style: TextStyle(
            color: Colors.white70, // Set the desired text color
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.black38, // Set the desired background color
      ),
      // This trailing comma makes auto-formatting nicer for build methods.

    );}
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Requests',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to Accept',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              content: Container(
                child: requests.isEmpty
                    ? const Center(
                  child: Text(
                    'No requests',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    String name = requests[index]['name'] ?? '';
                    String email = requests[index]['email'] ?? '';

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // Close the popup
                        setState(() {
                          tickets["loading"] = true;
                        });
                        Firebase_auth firebaseAuth = Firebase_auth();
                        firebaseAuth
                            .acceptRequest(
                          FirebaseAuth.instance.currentUser?.email ??
                              "Unknown",
                          FirebaseAuth.instance.currentUser?.displayName ??
                              "Unknown",
                          email,
                          name,
                        )
                            .then((_) {
                          // This block will be executed after the acceptRequest task is complete
                          _refreshWidget();
                        });

                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        color: Colors.teal, // Change the color as needed
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Remove the Icon
                              SizedBox(width: 6),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.white12),
                  child: const Text('Done' ,
                    style: TextStyle(
                      color: Colors.black,

                    ),),
                )

              ],
            );
          },
        );
      },
    );
  }

  void _addTicket(String name , String email , int total , String accept , String send) {
    setState(() {
      tickets["tickets"].add( {'name': name, 'email': email , 'total' : 'Rs : ${total.toString()}',
        'request' : {
          'accept' : accept,
          'send' : send ,
          'recieve' : "false"
        }});
    });
  }


  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(

          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: () {
                // Handle sign out option
                Navigator.pop(context);
                Firebase_auth firebaseAuth = Firebase_auth();
                firebaseAuth.signOutFromGoogle().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                });

              },
            ),
          ],
        );


      },
    );
  }

  void _showEditor(BuildContext context) {
    final emailFocusNode = FocusNode();
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Warning ! ',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            content: Text(message,
              style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500
            ),),
            actions: <Widget>[

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                },
                style: ElevatedButton.styleFrom(primary: Colors.white12),
                child: const Text('Ok' ,
                  style: TextStyle(
                    color: Colors.black,

                  ),),
              )
            ],
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add Friend",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center-align the text
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: emailController,
                focusNode: emailFocusNode,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {

                      // Validate email format
                      RegExp emailRegExp = RegExp(
                          r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      bool isEmailValid =
                      emailRegExp.hasMatch(emailController.text);

                      if (emailController.text.isEmpty ||
                          nameController.text.isEmpty) {
                        // Show a required message if any field is empty
                        showErrorDialog('Both email and name are required.');
                      } else if (!isEmailValid) {
                        // Show an invalid email format message
                        showErrorDialog('Please enter a valid email address.');
                      }
                      else if(emailController.text == FirebaseAuth.instance.currentUser?.email ) {
                        showErrorDialog('Please enter friend email not yours');
                      }else {
                        Navigator.pop(context);

                        setState(() {
                          tickets["loading"] = true;
                        });
                        var name = nameController.text;
                        var email = emailController.text;
                        Firebase_auth firebaseAuth = Firebase_auth();
                        firebaseAuth
                            .addUsers(
                          FirebaseAuth.instance.currentUser?.email ?? "Unknown",
                          FirebaseAuth.instance.currentUser?.displayName ??
                              "Unknown",
                          email,
                          name,
                        )
                            .then((bool result) {
                          if (result) {
                            _addTicket(name, email, 0, "true", "false");
                          } else {
                            _addTicket(name, email, 0, "false", "true");
                          }
                          _refreshWidget();
                        });

                        nameController.text = '';
                        emailController.text = '';
                        // You can perform additional actions with the request data
                      }
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.indigo),
                    child: const Text('Add',
                        style: TextStyle(
                          color: Colors.white,

                        )),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      nameController.text = '';
                      emailController.text = '';
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.white12),
                    child: const Text('Cancel',
                        style: TextStyle(
                          color: Colors.black,

                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }







}





