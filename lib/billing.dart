import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firbase/firbase_auth.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crypto/crypto.dart';

class BillingStatefulWidget extends StatefulWidget {
  const BillingStatefulWidget({super.key, required this.title ,required this.email  ,required this.name });


  final String title;
  final String email;
  final String name;



  @override
  State<BillingStatefulWidget> createState() => _BillingPageState();
}


class _BillingPageState extends State<BillingStatefulWidget> {


  // Define controllers
  TextEditingController dateTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();

  var debits ,credits =[];
  Map<String, dynamic>  bills = {"loading" : true , "bills" : []};

  DateTime? _selectedDate = DateTime.now();

  String selectedValue = 'Credit';
  List<String> dropdownItems = ['Credit', 'Debit'];

  Map<String, Color> optionColors = {
    'Credit': Colors.deepOrangeAccent,
    'Debit': Colors.lightGreen,
    // Add more options and colors as needed
  };

  String? lastDate;
  int total = 0;

  var name =null ;

  bool deletePopupLoading = false;
  bool renamePopupLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshWidget();
  }

  int getTotalSum(var billings) {
    int sum=0;
    for (int i = 0; i < billings.length; i++) {
      int amount = int.parse(billings[i]["amount"]);
      String type = billings[i]["type"];

      if(type=="Credit"){sum-=amount;}
      else{sum+=amount;}
    }

    return sum;
  }

  Future<void> initializeBills() async {
    try {


      bills['loading'] = true;
      bills['bills'] =[];
      debits=[];
      credits=[];
      setState(() {
      });

      // Replace 'your_self_email' with the actual email you want to use
      String selfEmail =  FirebaseAuth.instance.currentUser?.email ?? "Unknown";
      var query = FirebaseFirestore.instance.collection(selfEmail).where('email', isEqualTo: widget.email);
      var querySnapshot = await query.get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;
        debits = data['billings'];
        name = data['name'];
      }

      query = FirebaseFirestore.instance.collection(widget.email).where('email', isEqualTo:selfEmail);
      querySnapshot = await query.get();
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;
        credits = data['billings'];

      }

      for (var i in debits){
        i["type"]="Debit";
        bills["bills"].add(i);
      }

      for (var i in credits) {
        i["type"] = "Credit";
        bills["bills"].add(i);
      }

      _billsSorter();
      total = getTotalSum(bills["bills"]);
      print(bills["loading"]);
      // Update the state to trigger a rebuild with the fetched data
    } catch (e) {
      print('Error initializing tickets: $e');
    }
  }

  void _billsSorter(){
    bills["bills"].sort((a, b) {
      // Assuming the date format is "YYYY-MM-DD"
      String dateA = a['date'] ?? '';
      String dateB = b['date'] ?? '';

      // Compare dates lexicographically
      return dateA.compareTo(dateB);
    });
  }

  void _refreshWidget() {
    initializeBills().then((value) {
      bills["loading"] = false;
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(name ?? widget.name ,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
          ),),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refreshWidget();
              },
            ),
            IconButton(
              icon: Icon(Icons.abc_outlined),
              onPressed: () {
                _renameWidget(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {

                _deleteProfile(context , widget.email  ,widget.name);
                
              },
            ),
      IconButton(
      icon: Icon(Icons.account_balance),
      onPressed: () {
        total = getTotalSum(bills["bills"]);
        // Implement the refresh logic here
        _showPopup(context);
      },
    ),
            ]
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0), // Adjust the top and bottom padding as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child:
                Container(
                    child:
                    bills["loading"]
                        ? const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black, // Set the color of the bubbles
                        size: 50.0, // Set the size of the spinner
                      ),
                    ) :
                    bills["bills"].isEmpty
                        ? const Center(
                      child: Text(
                        'No Bills',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ):
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: bills["bills"].length,
                      itemBuilder: (context, index) {
                        String date = bills["bills"][index]['date'] ?? '';
                        String description = bills["bills"][index]['description'] ?? '';
                        String amount = bills["bills"][index]['amount'] ?? '';
                        String type = bills["bills"][index]['type'] ?? 'black';

                        bool isDateChanged = lastDate != date;
                        lastDate = date;

                        return Column(
                          children: [
                            if (isDateChanged)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      date, // Display the date under the divider
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            InkWell(
                              onTap: () {
                                // Handle card tap
                                print('Card tapped:');
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                color: optionColors[type] ?? Colors.black, // Change the color as needed
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Text(
                                                description,
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Rs . ${amount}',
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            
                          ],
                        );
                      },
                    )
                ),
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
          "Add Bill",
          style: TextStyle(
            color: Colors.white70, // Set the desired text color
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.black38, // Set the desired background color
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }

  void _deleteProfile(BuildContext context,email ,name ) async {
    print("Delte");
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    deletePopupLoading ? "Deleting ..!" :"Do you want to delete ${name ?? "User"}?"
                    ,

                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  deletePopupLoading
                      ? [const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black, // Set the color of the bubbles
                      size: 50.0, // Set the size of the spinner
                    ),
                  ) ]:<Widget>[


                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {


                            deletePopupLoading=true;
                            setState((){});

                            String selfEmail = FirebaseAuth.instance.currentUser?.email ?? "Unknown";
                            CollectionReference usersRefSelf = FirebaseFirestore.instance.collection(
                                selfEmail);
                            CollectionReference usersRefOther = FirebaseFirestore.instance.collection(
                                email);

                            var querySnapshot_self = await usersRefSelf.where('email', isEqualTo: email)
                                .get();
                            var querySnapshot_other = await usersRefOther.where('email', isEqualTo: selfEmail)
                                .get();

                            if (querySnapshot_self.docs.isNotEmpty) {
                              var userDocument_self = querySnapshot_self.docs.first;
                              var documentId_self = userDocument_self.id;
                              await usersRefSelf
                                  .doc(documentId_self)
                                  .delete();
                            }

                            if (querySnapshot_other.docs.isNotEmpty) {
                              var userDocument_other = querySnapshot_other.docs.first;
                              var documentId_other = userDocument_other.id;

                              await usersRefOther
                                  .doc(documentId_other)
                                  .update({
                                'request' : {
                                  'accept' : "false",
                                  'send' : "false" ,
                                  'recieve' : "false",
                                  'delete' : "true"
                                }
                              });
                            }

                            deletePopupLoading=false;
                            setState((){});
                            Navigator.pop(context );
                            Navigator.pop(context, 42);

                          },
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          child: const Text('Delete',
                              style: TextStyle(
                                color: Colors.white,

                              )),
                        ),
                        ElevatedButton(
                          onPressed: () {

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
    );





    
  }

  void _renameWidget(BuildContext context){

    final newNameController = TextEditingController();

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
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Center(
                  child: Text(
                    "Rename ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:  renamePopupLoading
                  ? [const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black, // Set the color of the bubbles
                      size: 50.0, // Set the size of the spinner
                    ),
                  ) ]: <Widget>[
                    Container(
                      child: TextField(
                        controller: newNameController,
                        decoration: const InputDecoration(
                          hintText: 'New name',
                        ),

                      ),
                    ),

                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (newNameController.text.isEmpty ) {
                              showErrorDialog('All fields are required');
                            } else {
                              renamePopupLoading = true;
                              setState((){});
                              var selfemail = FirebaseAuth.instance.currentUser?.email ?? "Unknown";
                              var query = FirebaseFirestore.instance.collection(selfemail).where('email', isEqualTo: widget.email);
                              var querySnapshot = await query.get();
                              if (querySnapshot.docs.isNotEmpty) {
                                var userDocument = querySnapshot.docs.first;
                                var documentId = userDocument.id;

                                await FirebaseFirestore.instance.collection(selfemail).doc(documentId).update({
                                  'name' : newNameController.text
                                }).then((_) {
                                  renamePopupLoading = false;
                                  setState((){});
                                  Navigator.pop(context );
                                  Navigator.pop(context, 43);
                                });
                              }


                              newNameController.text = '';
                            }
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.indigo),
                          child: const Text('Rename',
                              style: TextStyle(
                                color: Colors.white,

                              )),
                        ),
                        ElevatedButton(
                          onPressed: () {

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
    );
  }
  
  void _showPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Total Balance : Rs . ${total}',
                  style: const TextStyle(
                    fontSize: 18, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),

              );

            },);

        }
    );
  }

  void _addTicket(String date , String description ,String amount , String type  ,String id) {
    setState(() {
      bills["bills"].add( {'date': date, 'description': description , 'amount' : amount , 'type' : type , 'id' : id});
    });
  }

  String generateUniqueId(String email , String desciption , String amount) {
    int milliseconds = DateTime.now().millisecondsSinceEpoch;
    String input = '$email-$milliseconds-$desciption-$amount';

    // Create an MD5 hash
    var bytes = utf8.encode(input);
    var md5Hash = md5.convert(bytes);

    // Convert the hash to a hexadecimal string
    String uniqueId = md5Hash.toString();

    return uniqueId;
  }

  void _showEditor(BuildContext context) {
    final TextEditingController amountTextController = TextEditingController();
    final TextEditingController descriptionTextController = TextEditingController();

    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState)
          {
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
          }
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Center(
                child: Text(
                  "Add Bill",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: amountTextController,
                      decoration: InputDecoration(
                        hintText: 'Amount',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ),
                  Container(
                    child: TextField(
                      controller: descriptionTextController,
                      decoration: InputDecoration(
                        hintText: 'Description',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      setState(() {
                        if (picked != null) {
                          _selectedDate = picked;
                        }
                      });
                    },
                    child: Text(' Date: ${DateFormat('yyyy-MM-dd').format(
                        _selectedDate!)}' ,
                        style: const TextStyle(
                          color: Colors.black,

                        )),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (amountTextController.text.isEmpty ||
                              descriptionTextController.text.isEmpty) {
                            showErrorDialog('All fields are required');
                          } else {
                            Navigator.pop(context);
                            String id = generateUniqueId(FirebaseAuth.instance.currentUser?.email ??
                                "Unknown", descriptionTextController.text, amountTextController.text);
                            Firebase_auth firebaseAuth = Firebase_auth();
                            firebaseAuth.addBills(
                              FirebaseAuth.instance.currentUser?.email ??
                                  "Unknown",
                              widget.email,
                              {
                                "date": DateFormat('yyyy-MM-dd').format(
                                    _selectedDate!),
                                "description": descriptionTextController.text,
                                "amount": amountTextController.text,
                                "id" : id
                              },
                            );
                            _addTicket(
                              DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              descriptionTextController.text,
                              amountTextController.text,
                              "Debit",
                              id
                            );
                            _billsSorter();
                            setState(() {});

                            descriptionTextController.text = '';
                            amountTextController.text = '';
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
                          descriptionTextController.text = '';
                          amountTextController.text = '';
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
    );
  }

}


