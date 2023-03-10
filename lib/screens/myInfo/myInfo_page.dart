import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_screen.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreen();
}

class _MyInfoScreen extends State<MyInfoScreen> {
  final _authentication = FirebaseAuth.instance;

  late String userEmail = _authentication.currentUser!.email.toString();
  late String userUid = _authentication.currentUser!.uid.toString();
  late String userID = "";
  late String userName = "";
  late String userNickname = "";
  late String userPhonenum = "";

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordChangeController =
      TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    readInfo();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.orange[300],
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  Future<void> readInfo() async {
    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection("userInfo");
    var snapshot = await collectionReference.doc(userUid).get();

    setState(() {
      userID = snapshot.get("id") as String;
      userName = snapshot.get("name").toString();
      userNickname = snapshot.get("nickname").toString();
      userPhonenum = snapshot.get("phonenum").toString();
    });
  }

  Future setLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', false);
    prefs.setString('uid', "");
    showToast("???????????? ???????????????.");
  }

  Future<void> clickChange() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: userEmail, password: _passwordController.text);
      user = userCredential.user;
      if (user != null) {
        showToast("??????????????? ???????????????.");
        if (_passwordChangeController.text.isNotEmpty) {
          changePW();
        }
        if (_nickNameController.text.isNotEmpty) {
          changeNickname();
        }
      } else {
        showToast("??????????????? ???????????? ????????????.\n??????????????? ?????? ??????????????????.");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> changePW() async {
    try {
      var user = _authentication.currentUser;

      user!.updatePassword(_passwordChangeController.text).then((value) {
        showToast("??????????????? ?????????????????????.");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('??????????????? 6??? ?????? ??????????????????.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> changeNickname() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    final example = <String, String>{
      "nickname": _nickNameController.text,
    };

    await db
        .collection("userInfo")
        .doc("$userUid")
        .update(example)
        .then((value) => showToast("???????????? ?????????????????????."))
        .onError((e, _) => print(e));
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _passwordChangeController.dispose();
    _nickNameController.dispose();
  }

  Widget _userIdWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: EdgeInsets.fromLTRB(10, 16, 20, 16),
        child: Text("??????  $userID"));
  }

  Widget _passwordWidget() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '???????????? ??????',
          hintText: '?????? pw'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return '?????? ??????????????? ??????????????????.';
        }
        return null;
      },
    );
  }

  Widget _passwordChangeWidget() {
    return TextFormField(
      controller: _passwordChangeController,
      obscureText: true,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: '????????????', hintText: '?????? pw'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return '?????? ??????????????? ??????????????????.';
        }
        return null;
      },
    );
  }

  Widget _nameWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: EdgeInsets.fromLTRB(10, 16, 20, 16),
        child: Text("??????  $userName"));
  }

  Widget _emailWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: EdgeInsets.fromLTRB(10, 16, 20, 16),
        child: Text("Email  $userEmail"));
  }

  Widget _phoneNumWidget() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: EdgeInsets.fromLTRB(10, 16, 20, 16),
        child: Text("????????????  $userPhonenum"));
  }

  Widget _nickNameWidget() {
    return TextFormField(
      controller: _nickNameController,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: '?????????', hintText: '?????? ?????????'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return '???????????? ??????????????????.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = const Color.fromARGB(255, 64, 196, 255);
    return Scaffold(
      appBar: AppBar(
        title: const Text("??? ??????"),
        backgroundColor: backColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 15,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _nameWidget(),
              const SizedBox(height: 20.0),
              _emailWidget(),
              const SizedBox(height: 20.0),
              _passwordWidget(),
              const SizedBox(height: 20.0),
              _passwordChangeWidget(),
              const SizedBox(height: 20.0),
              _userIdWidget(),
              const SizedBox(height: 20.0),
              _phoneNumWidget(),
              const SizedBox(height: 20.0),
              _nickNameWidget(),
              Container(
                  height: 70,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              clickChange();
                            },
                            child: const Text("??????")),
                        const SizedBox(width: 40.0),
                        ElevatedButton(
                            onPressed: () {
                              _authentication.signOut();
                              setLogout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (builder) => Mainhomepage()),
                                (route) => false,
                              );
                            },
                            child: const Text("????????????")),
                      ])),
            ],
          ),
        ),
      ),
    );
  }
}
