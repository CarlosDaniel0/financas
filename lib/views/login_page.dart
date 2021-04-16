import 'package:flutter/material.dart';
import '../views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle(ScaffoldState state) async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      ScaffoldMessenger.of(state.context)
          .showSnackBar(SnackBar(content: Text('Login Cancelado!')));
      //state.showSnackBar(SnackBar(content: Text('Login Cancelado!')));
    } else {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      ScaffoldMessenger.of(state.context).showSnackBar(
          SnackBar(content: Text('Login efetuado com sucesso! Aguarde...')));

      final UserCredential authRequest =
          await _auth.signInWithCredential(credential);
      final User user = authRequest.user;

      if (user != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final User currentUser = _auth.currentUser;
        assert(user.uid == currentUser.uid);
        print('Sign In with Google succeeded: $user ');
      }
      return true;
    }

    return false;
  }

  // void signOutGoogle() async {
  //   await googleSignIn.signOut();
  //   print('User Sign Out');
  // }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 50),
              SizedBox(height: 150),
              _signInButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlinedButton(
      onPressed: () {
        signInWithGoogle(_scaffoldKey.currentState).then((result) => {
              if (result)
                {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (route) => false)
                }
            });
      },
      style: ButtonStyle(
        //  shape: MaterialStateProperty.all(OutlinedBorder(side: BorderSide.none, ).),
        elevation: MaterialStateProperty.all(0),
        foregroundColor: MaterialStateProperty.all(Colors.grey),
      ),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/google_logo.png',
                  height: 35,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Login com o Google',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              ])),
    );
  }
}
