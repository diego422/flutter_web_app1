import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormularioPage extends StatefulWidget {
  const FormularioPage({super.key});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gmailController = TextEditingController();
  final _ageController = TextEditingController();
  final _countryController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('formulario').add({
        'name': _nameController.text,
        'gmail': _gmailController.text,
        'age': _ageController.text,
        'country': _countryController.text,
        'date of birth': _dobController.text,
        'phone number': _phoneController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados en Firebase 🎉')),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _gmailController.clear();
      _ageController.clear();
      _countryController.clear();
      _dobController.clear();
      _phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario Firebase"),
        actions: [
          IconButton(
            tooltip: 'Nuevo suministro',
            icon: const Icon(Icons.inventory_2),
            onPressed: () => Navigator.pushNamed(context, '/suministro'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => (v == null || v.isEmpty) ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _gmailController,
                decoration: const InputDecoration(labelText: "Gmail"),
                validator: (v) => (v == null || v.isEmpty) ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: "Country"),
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text("Guardar en Firebase"),
              ),
            ],
          ),
        ),
      ),
      // Alternativa adicional:
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.inventory),
        label: const Text('Suministro'),
        onPressed: () => Navigator.pushNamed(context, '/suministro'),
      ),
    );
  }
}
