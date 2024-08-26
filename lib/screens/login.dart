import 'package:firebase_auth/firebase_auth.dart';
import '../screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals/myFonts.dart';
import '../providers/authentication.dart';
import '../screens/signup.dart';
import '../widgets/auth_screen_intro.dart';
import '../globals/sizeConfig.dart';
import '../globals/myColors.dart';
import '../miscellaneous/functions.dart' as func;
import '../providers/tasks.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  var isLoading = false;

  void tryLogIn() async {
    if (!_formKey.currentState!.validate()) {
      return null;
    }
    _formKey.currentState!.save();
    final authInstance = Provider.of<Authentication>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      await authInstance.login(_email, _password);
      if(!FirebaseAuth.instance.currentUser!.emailVerified){
        await authInstance.signOut().then((value) {
          setState(() {
            isLoading = false;
          });
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  "Por favor, verifique seu e-mail antes de fazer login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                    "Um e-mail de verificação já foi enviado para seu endereço de e-mail registrado."
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                        "Ok",
                        style: TextStyle(
                          color: kBlue,
                          fontSize: SizeConfig.textScaleFactor * 20,
                        )
                    ),
                  ),
                ],
              );
            }
          );
        }).catchError((error){
          func.showError(error.toString(), context);
        });
      }
      else {
        Provider.of<Tasks>(context, listen: false).fetchAndSet(true);
        Navigator.of(context).pushReplacementNamed(CalendarScreen.routeName);
      }
    } catch (error) {
      func.showError(error.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void passwordReset() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: TextFormField(
            onChanged: (value) {
              _email = value;
            },
            decoration: InputDecoration(
              labelText: "Por favor, insira seu e-mail",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final _auth = FirebaseAuth.instance;
                final list = await _auth.fetchSignInMethodsForEmail(_email);
                if(list.isNotEmpty){
                  try {
                    await _auth.sendPasswordResetEmail(email: _email);
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(
                            "Link de redefinição de senha enviado com sucesso",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                  "Ok",
                                  style: TextStyle(
                                    color: kBlue,
                                    fontSize: SizeConfig.textScaleFactor * 20,
                                  )
                              ),
                            ),
                          ],
                        );
                      }
                    );
                  } catch (error) {
                    Navigator.of(context).pop();
                    func.showError(error.toString(), context);
                  }
                } else {
                  Navigator.of(context).pop();
                  func.showError("Nenhuma conta encontrada com este e-mail", context);
                }
              },
              child: Text(
                "Enviar link para redefinição de senha",
                style: TextStyle(
                  color: kBlue,
                  fontSize: SizeConfig.textScaleFactor * 20,
                )
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(),
      ) :
      LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight,
                  child: Image(
                    image: AssetImage(
                      "assets/images/background.jpg"
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraint.maxHeight
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthScreenIntro(),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.horizontalBlockSize * 5,
                          ),
                          height: 450,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig.screenHeight * 0.05,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: kGreyLite,
                                    contentPadding: EdgeInsets.fromLTRB(
                                      12, 10, 12, 10
                                    ),
                                    labelText: "Email",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12.0)
                                      ),
                                      borderSide: BorderSide(
                                        color: kGrey
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12.0)
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.red
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onSaved: (value) {
                                    _email = value!;
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Por favor, insira seu e-mail";
                                    }
                                    if (!value.contains("@") ||
                                        !value.contains(".")) {
                                      return "Por favor, insira um endereço de e-mail válido";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: kGreyLite,
                                    contentPadding: EdgeInsets.fromLTRB(
                                      12, 10, 12, 10
                                    ),
                                    labelText: "Senha",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12.0)
                                      ),
                                      borderSide: BorderSide(
                                        color: kGrey
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12.0)
                                      ),
                                      borderSide: BorderSide(
                                         color: Colors.red
                                      ),
                                    ),
                                  ),
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  onSaved: (value) {
                                    _password = value!;
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Por favor, digite uma senha";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    passwordReset();
                                  },
                                  child: Text(
                                    "Esqueceu sua senha?",
                                    style: MyFonts.medium.tsFactor(18).setColor(kGrey),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 12
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      tryLogIn();
                                    },
                                    child: Text(
                                      "Conecte-se",
                                      style: MyFonts.medium.factor(5),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      fixedSize: Size(1000, 50),
                                      // primary: Colors.purple[700],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Não tem uma conta? ",
                                      style: MyFonts.medium.tsFactor(18).setColor(kGrey),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamedAndRemoveUntil(SignUp.routeName,(route) => false);
                                      },
                                      child: Text(
                                        "Inscrever-se",
                                        style: MyFonts.bold.tsFactor(18),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
