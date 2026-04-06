import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to capture input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _relationController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Mapping form data to the keys EXACTLY as expected by the backend
      final userData = {
        'fullName': _nameController.text, // Updated: Backend expects fullName
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'aadhaar': _aadhaarController.text,
        'emergencyContact': _emergencyContactController.text,
        'emergencyContactRelation': _relationController.text, // MATCHES backend key
      };

      print('DEBUG: Sending userData: $userData');

      try {
        final success = await ApiService.register(userData);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful! Please Login.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Go back to Login screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Failed. Check backend logs or email existence.'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _aadhaarController.dispose();
    _emergencyContactController.dispose(); 
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Tourist Registration'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Personal Identity (KYC)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name (as per ID)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email (Gmail)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Aadhaar Number (12-digit)', border: OutlineInputBorder()),
                validator: (v) => v!.length != 12 ? 'Enter valid 12-digit Aadhaar' : null,
              ),
              const SizedBox(height: 24),
              const Text('Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relation of Emergency Contact', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter relation' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyContactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Emergency Contact Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Enter emergency contact' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                validator: (v) => v!.length < 6 ? 'Password too short' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
