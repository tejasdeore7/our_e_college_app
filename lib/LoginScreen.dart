import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;
import 'app.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    global.email = data.name;
    global.password = data.password;
    if (data.name == "teacher@gmail.com") {
      global.user = "Teacher";
    } else {
      global.user = "Student";
    }

    return Future.delayed(loginTime).then((_) async {
      try {
        String url = 'https://college-app-backend.herokuapp.com/api/login';
        final body = json.encode({
          "user": {"email": data.name, "password": data.password}
        });
        final response = await http.post(Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
            },
            body: body);
        final responseJson = json.decode(response.body);
        final accessToken = responseJson['accessToken'];
        final refreshToken = responseJson['refreshToken'];
        if (accessToken != null && refreshToken != null) {
          final storage = new FlutterSecureStorage();
          await storage.write(key: "accessToken", value: accessToken);
          await storage.write(key: "refreshToken", value: refreshToken);
        }
        print('response ${response.statusCode} ${response.body}');
        if (response.statusCode != 200) {
          if (responseJson['msg'] == null) {
            if (responseJson['error'] == null) {
              return "Unexpected error";
            }
            return responseJson['error'];
          }
          return responseJson['msg'];
        }
      } on SocketException catch (e) {
        return "Unexpected error";
      }
      return null;
    });
  }

  Future<String> _resetPassword(String email) async {
    return Future.delayed(loginTime).then((_) async {
      // try {
      //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      //   await firebaseAuth.sendPasswordResetEmail(email: email);
      // } on FirebaseAuthException catch (e) {
      //   if (e.code == 'user-not-found') {
      //     return 'No user found for that email.';
      //   }
      // }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onSignup: null,
      onLogin: _authUser,
      onSubmitAnimationCompleted: () async {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('email', global.email);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => App(),
        ));
      },
      hideSignUpButton: true,
      onRecoverPassword: _resetPassword,
      theme: LoginTheme(
        primaryColor: Colors.deepOrange,
      ),
      messages: LoginMessages(
          recoverPasswordDescription:
              'We will send you an email to reset your password for the above account.'),
    );
  }
}
