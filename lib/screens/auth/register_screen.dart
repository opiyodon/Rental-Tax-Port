import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/home/home_screen.dart';
import 'package:rental_tax_port/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String userType = 'Landlord';
  String kraPinNumber = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Password'),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                const SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  value: userType,
                  decoration: const InputDecoration(labelText: 'User Type'),
                  items: <String>['Landlord', 'Tenant', 'Agent', 'Admin']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      userType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                if (userType == 'Landlord')
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'KRA PIN Number'),
                    validator: (val) => val!.isEmpty ? 'Enter KRA PIN Number' : null,
                    onChanged: (val) {
                      setState(() => kraPinNumber = val);
                    },
                  ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  child: const Text('Register'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (userType == 'Landlord') {
                        bool isVerified = await _auth.verifyKraPinNumber(kraPinNumber);
                        if (!isVerified) {
                          setState(() => error = 'Invalid KRA PIN Number');
                          return;
                        }
                      }
                      dynamic result = await _auth.signUp(email, password, userType, kraPinNumber);
                      if (result == null) {
                        setState(() => error = 'Please supply a valid email');
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}