import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final picker = ImagePicker();
  bool loading = false;
  String profileImageUri;

  Future saveFile() async {
    User user = FirebaseAuth.instance.currentUser;
    var uid = user.uid;
    var student;
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
        student = documentSnapshot.data();
        try {
          await FirebaseStorage.instance
              .ref('Batch/${student["batch"]}/Branch/${student["branch"]}/Students/${student["rollno"]}/Profile-Photo/bt19cse005')
              .putFile(File(profileImageUri))
              .then((snapshot) async {
            CollectionReference studentCollection = FirebaseFirestore.instance
                .collection('Students');
            await studentCollection
                .doc(student["uid"])
                .update({'profilePhotoUri': await snapshot.ref.getDownloadURL()})
                .then((value) {
              setState(() {
                loading =false;
              });
              print("User Updated");
            })
                .catchError((error) => print("Failed to update user: $error"));
                print("snapshot uri ${ await snapshot.ref.getDownloadURL()}");
          });
        } on FirebaseException catch (e) {
          // e.g, e.code == 'canceled'
          print(e.code);
        }
    });
  }

  Future getProfileImageFromDatabase() async {
    User user = FirebaseAuth.instance.currentUser;
    var uid = user.uid;
    var student;
    return await FirebaseFirestore.instance
        .collection('Students')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        return await documentSnapshot["profilePhotoUri"];
        print("student ${student}");
      } else {
        print('Document does not exist on the student database');
      }
    });
  }



  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      profileImageUri = pickedFile.path;
    });
    //print("upload file ${await uploadFile(pickedFile.path)}");
    //uploadFile(pickedFile.path);
  }

  bool showPassword = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getProfileImageFromDatabase();
    print("profileImage $profileImageUri");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.orange,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 4,
                                color: Theme.of(context).scaffoldBackgroundColor),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 10))
                            ],
                            shape: BoxShape.circle,
                          
                        ),
                        child: (profileImageUri!=null)?
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: FileImage(File(profileImageUri)),
                        ):
                        FutureBuilder(
                          future: getProfileImageFromDatabase(),
                          builder:(context,snapshot){
                            if (snapshot.connectionState == ConnectionState.done) {
                              print(snapshot);
                              if(snapshot.hasData && snapshot.data.length >0){
                                return  CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(snapshot.data),
                                );
                              }
                              else{
                                return  CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage("assets/splash.jpg",),
                                );
                              }

                            }
                            return CircularProgressIndicator();
                          },
                        ),
                        ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.green,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              buildTextField("Full Name", "Dor Alex"),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if(profileImageUri!=null){
                        setState(() {
                          loading =true;
                        });
                        saveFile();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:MaterialStateProperty.all<Color>(Colors.green),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 50,vertical: 5)),
                      elevation: MaterialStateProperty.all<double>(2),
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                    ),
                    child: (loading==true)?
                    CircularProgressIndicator(
                      color: Colors.white,
                    ):
                    Text("Save",
                    style: TextStyle(
                      fontSize: 14
                    ),),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
      ),
    );
  }
}
