import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import '../theme/app_theme.dart';

class AddAgencyScreen extends StatefulWidget {
  const AddAgencyScreen({super.key});

  @override
  State<AddAgencyScreen> createState() => _AddAgencyScreenState();
}

class _AddAgencyScreenState extends State<AddAgencyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _managerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;

  double? _lat;
  double? _lng;

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Nouvelle Agence',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: BackButton(color: AppTheme.primaryRed),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_nameController, 'Nom de l’agence', Icons.business),
              const SizedBox(height: 16),
              _input(_managerController, 'Responsable', Icons.person),
              const SizedBox(height: 16),
              _input(
                _phoneController,
                'Téléphone',
                Icons.phone,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _mapSection(),
              const SizedBox(height: 20),
              _addressField(),
              const SizedBox(height: 30),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------- MAP ----------------

  Widget _mapSection() {
    return SizedBox(
      height: 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapWidget(
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(-7.5898, 33.5731), // Casablanca
            ),
            zoom: 12,
          ),
          onMapCreated: _onMapCreated,
          onTapListener: (context) {
            _onMapTap(context);
          },
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointManager = await _mapboxMap!.annotations
        .createPointAnnotationManager();
  }

  Future<void> _onMapTap(MapContentGestureContext context) async {
    final point = context.point;

    final lat = point.coordinates.lat.toDouble();
    final lng = point.coordinates.lng.toDouble();

    await _pointManager?.deleteAll();

    await _pointManager?.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        iconSize: 1.3,
      ),
    );

    setState(() {
      _lat = lat;
      _lng = lng;
      _addressController.text =
          'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
    });
  }

  // ---------------- LOCATION ----------------

  // ---------------- ADDRESS ----------------

  Widget _addressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      validator: (v) => v == null || v.isEmpty ? 'Adresse obligatoire' : null,
      decoration: InputDecoration(
        labelText: 'Adresse',
        prefixIcon: const Icon(Icons.location_on),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
        onPressed: _submit,
        child: const Text(
          'CRÉER AGENCE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      debugPrint('Nom: ${_nameController.text}');
      debugPrint('Lat: $_lat | Lng: $_lng');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _managerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
