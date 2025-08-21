import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExistenciasPage extends StatefulWidget {
  final String suministroId;
  final String suministroNombre;
  const ExistenciasPage({super.key, required this.suministroId, required this.suministroNombre});

  @override
  State<ExistenciasPage> createState() => _ExistenciasPageState();
}

class _ExistenciasPageState extends State<ExistenciasPage> {
  final colSedes = FirebaseFirestore.instance.collection('sedes');
  final colExist = FirebaseFirestore.instance.collection('existencias');
  final Map<String, TextEditingController> _ctrls = {}; // sedeId -> ctrl

  bool _loading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sedes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    // 1) Sedes
    final sedesSnap = await colSedes.orderBy('nombre').get();
    _sedes = sedesSnap.docs;

    // 2) Existencias del suministro
    final exSnap = await colExist.where('suministroId', isEqualTo: widget.suministroId).get();
    final existMap = { for (var d in exSnap.docs) d['sedeId'] as String : d };

    // 3) Prellenar controles
    for (final sede in _sedes) {
      final sedeId = sede.id;
      final cantidad = existMap[sedeId]?['cantidad'] ?? 0;
      _ctrls[sedeId] = TextEditingController(text: cantidad.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _guardar() async {
    final batch = FirebaseFirestore.instance.batch();
    final now = FieldValue.serverTimestamp();

    for (final sede in _sedes) {
      final sedeId = sede.id;
      final txt = _ctrls[sedeId]!.text.trim();
      final cant = int.tryParse(txt) ?? 0;

      // busca si ya existe documento existencia(suministroId, sedeId)
      final q = await colExist
          .where('suministroId', isEqualTo: widget.suministroId)
          .where('sedeId', isEqualTo: sedeId)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        // crea
        final ref = colExist.doc();
        batch.set(ref, {
          'suministroId': widget.suministroId,
          'sedeId': sedeId,
          'cantidad': cant,
          'updatedAt': now,
          'createdAt': now,
        });
      } else {
        // actualiza
        batch.update(q.docs.first.reference, {
          'cantidad': cant,
          'updatedAt': now,
        });
      }
    }

    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventario guardado por sede')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Existencias • ${widget.suministroNombre}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _sedes.length,
              itemBuilder: (_, i) {
                final sede = _sedes[i].data();
                final sedeId = _sedes[i].id;
                return Card(
                  child: ListTile(
                    title: Text(sede['nombre'] ?? 'Sede'),
                    subtitle: Text(sede['distrito'] ?? ''),
                    trailing: SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _ctrls[sedeId],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cant.'),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save),
            label: const Text('Guardar inventario'),
          ),
        ),
      ),
    );
  }
}
