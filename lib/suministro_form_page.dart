import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuministroFormPage extends StatefulWidget {
  final String? id; // si viene, edita
  const SuministroFormPage({super.key, this.id});

  @override
  State<SuministroFormPage> createState() => _SuministroFormPageState();
}

class _SuministroFormPageState extends State<SuministroFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _categoria = TextEditingController();
  final _cantidad = TextEditingController();
  final _unidad = TextEditingController();
  final _ubicacion = TextEditingController();
  bool _activo = true;

  final _col = FirebaseFirestore.instance.collection('suministros');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final doc = await _col.doc(widget.id!).get();
    final d = doc.data();
    if (d != null) {
      _nombre.text = d['nombre'] ?? '';
      _categoria.text = d['categoria'] ?? '';
      _cantidad.text = '${d['cantidad'] ?? ''}';
      _unidad.text = d['unidad'] ?? '';
      _ubicacion.text = d['ubicacion'] ?? '';
      _activo = (d['activo'] ?? true) as bool;
    }
    setState(() => _loading = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'nombre': _nombre.text.trim(),
      'categoria': _categoria.text.trim(),
      'cantidad': int.parse(_cantidad.text),
      'unidad': _unidad.text.trim(),
      'ubicacion': _ubicacion.text.trim(),
      'activo': _activo,
      'updatedAt': FieldValue.serverTimestamp(),
      if (widget.id == null) 'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() => _loading = true);
    try {
      if (widget.id == null) {
        await _col.add(data);
      } else {
        await _col.doc(widget.id!).update(data);
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.id == null ? 'Creado' : 'Actualizado')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _categoria.dispose();
    _cantidad.dispose();
    _unidad.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.id != null;
    return Scaffold(
      appBar: AppBar(title: Text(edit ? 'Editar suministro' : 'Nuevo suministro')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nombre,
                      decoration: const InputDecoration(labelText: 'Nombre *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    TextFormField(
                      controller: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    TextFormField(
                      controller: _cantidad,
                      decoration: const InputDecoration(labelText: 'Cantidad *'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 0) return 'Ingrese un número válido';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _unidad,
                      decoration: const InputDecoration(labelText: 'Unidad (cajas, kg, u)'),
                    ),
                    TextFormField(
                      controller: _ubicacion,
                      decoration: const InputDecoration(labelText: 'Ubicación (estante, sala, etc.)'),
                    ),
                    SwitchListTile(
                      value: _activo,
                      title: const Text('Activo'),
                      onChanged: (v) => setState(() => _activo = v),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save),
                      label: Text(edit ? 'Guardar cambios' : 'Crear'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
