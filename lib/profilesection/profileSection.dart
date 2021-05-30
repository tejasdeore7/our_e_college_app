import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:our_e_college_app/LoginScreen.dart';
import 'package:our_e_college_app/profilesection/ProfileListItems/changepassword.dart';
import 'package:our_e_college_app/profilesection/ProfileListItems/editprofile.dart';
import 'package:our_e_college_app/profilesection/profilephoto.dart'
    as ProfilePhoto;
import 'package:our_e_college_app/profilesection/profilelistitem.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                height: 100,
                width: 100,
                margin: EdgeInsets.only(top: 30),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    CircleAvatar(
                      radius: 50,
                      foregroundImage: ProfilePhoto.image == null
                          ? AssetImage('splash.jpg')
                          : FileImage(ProfilePhoto.image),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Harsh Shrivastava',
              ),
              SizedBox(height: 5),
              Text(
                'BT19CSE006@iitn.com',
              ),
              SizedBox(height: 20),
              Expanded(
                  child: Column(children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView(
                  children: [
                    ProfileListItems(
                      icon: Icons.edit,
                      text: 'Edit Profile',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EditProfile()));
                      },
                    ),
                    ProfileListItems(
                      icon: Icons.password,
                      text: 'Change Password',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChangePassword()));
                      },
                    ),
                    ProfileListItems(
                      icon: Icons.book,
                      text: 'Backlogs',
                      onPressed: () {},
                    ),
                    ProfileListItems(
                      icon: Icons.calendar_today,
                      text: 'Acadmic Calendar',
                      onPressed: () {},
                    ),
                    ProfileListItems(
                      icon: Icons.notifications,
                      text: 'Notification',
                      onPressed: () {},
                    ),
                    ProfileListItems(
                      icon: Icons.security,
                      text: 'About Us',
                      onPressed: () {},
                    ),
                    ProfileListItems(
                        icon: Icons.logout,
                        text: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.remove('email');
                          Navigator.pushReplacement(
                              ContextKeeper.buildContext,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen()));
                        }),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ))
              ])),
            ],
          ),
        ));
  }
}
