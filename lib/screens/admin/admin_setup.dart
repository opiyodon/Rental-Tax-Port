import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({Key? key}) : super(key: key);

  @override
  _AdminSetupScreenState createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminCodeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _setupAdminConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Check if config already exists
      final docSnapshot = await firestore
          .collection('config')
          .doc('admin_settings')
          .get();

      if (!docSnapshot.exists) {
        await firestore
            .collection('config')
            .doc('admin_settings')
            .set({
              'admin_code': _adminCodeController.text,
              'created_at': FieldValue.serverTimestamp(),
              'last_updated': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin configuration created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await firestore
            .collection('config')
            .doc('admin_settings')
            .update({
              'admin_code': _adminCodeController.text,
              'last_updated': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin configuration updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear the form
      _adminCodeController.clear();
    } catch (e) {
      setState(() {
        _error = 'Error setting up admin configuration: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _adminCodeController,
                decoration: const InputDecoration(
                  labelText: 'Admin Code',
                  hintText: 'Enter secure admin code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an admin code';
                  }
                  if (value.length < 6) {
                    return 'Admin code must be at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _setupAdminConfig,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Admin Configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adminCodeController.dispose();
    super.dispose();
  }
}