import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes
import 'package:signature/signature.dart'; // Importar paquete para firma
import 'login.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Para manejar archivos (imágenes seleccionadas)
//import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final String username = "Admin"; // Variable para el nombre de usuario

  List<File> _imageFiles = []; // Lista de archivos de imágenes seleccionadas
  final ImagePicker _picker = ImagePicker();
  Map<String, int> _pieceCounts = {}; // Mapa para contar las piezas agregadas
  final TextEditingController _retroalimentacionController = TextEditingController();
  String? _selectedInstalacion;
  List<String> _selectedPiezas = []; // Lista para almacenar piezas seleccionadas
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<String> _submittedResponses = []; // Lista para almacenar respuestas enviadas

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  // Método para obtener la fecha actual
  String _getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  // Método para seleccionar imágenes desde la galería
  Future<void> _pickImage() async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo puedes subir hasta 5 imágenes')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path)); // Agrega la imagen seleccionada a la lista
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedInstalacion = null;
      _selectedPiezas.clear();
      _retroalimentacionController.clear();
      _imageFiles.clear();
      _pieceCounts.clear(); // Reiniciar contador de piezas
      _signatureController.clear(); // Clear the signature pad
    });
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username[0],
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 87, 0),
            ),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Respuestas Enviadas'),
            onTap: () {
              _showSubmittedResponses(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _showSubmittedResponses(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respuestas Enviadas'),
          content: _submittedResponses.isEmpty
              ? Text('No se han enviado respuestas.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _submittedResponses.map((response) {
                    return ListTile(
                      title: Text(response),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    );
                  }).toList(),
                ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permiso de almacenamiento concedido')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permiso de almacenamiento denegado')));
    }
  }

  Future<void> _savePdf() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        final pdf = pw.Document();
        final signature = await _signatureController.toPngBytes();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Reporte de Instalación', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Usuario: $username'),
                  pw.Text('Tipo de Instalación: $_selectedInstalacion'),
                  pw.Text('Piezas: ${_selectedPiezas.join(', ')}'),
                  pw.Text('Fecha: ${_getCurrentDate()}'),
                  pw.Text('Retroalimentación: ${_retroalimentacionController.text}'),
                  pw.SizedBox(height: 20),
                  pw.Text('Firma:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  if (signature != null) pw.Image(pw.MemoryImage(signature), height: 100, width: 200),
                ],
              );
            },
          ),
        );

        final directory = await getExternalStorageDirectory();
        final file = File('${directory!.path}/reporte_${_getCurrentDate()}.pdf');
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF guardado en ${file.path}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar el PDF: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permiso de almacenamiento denegado')));
    }
  }

  // Método para mostrar el diálogo con la imagen seleccionada
  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(imageFile),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionnaire() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reporte de Instalación',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Pregunta 1: Usuario
            _buildUserQuestion('Usuario', username),

            // Pregunta 2: Instalación
            _buildDropdownQuestion(
              'Tipo de Instalación',
              _selectedInstalacion,
              ['Instalación', 'Reparación', 'Limpieza'],
              (String? newValue) {
                setState(() {
                  _selectedInstalacion = newValue;
                });
              },
            ),

            // Pregunta 3: Pieza
            _buildMultiSelectPiezaQuestion(),

            // Pregunta 4: Fecha (Automática)
            _buildDateQuestion('Fecha', _getCurrentDate()),

            // Pregunta 5: Retroalimentación
            _buildTextInputQuestion(
              'Retroalimentación',
              _retroalimentacionController,
            ),

            // Pregunta 6: Fotografía (Subir hasta 5 imágenes)
            _buildPhotoQuestion(),

            SizedBox(height: 20),
            _buildSignaturePad(), // Agregar recuadro de firma
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Aquí puedes agregar funcionalidad para procesar las respuestas
                setState(() {
                  _submittedResponses.add('Respuestas enviadas el ${_getCurrentDate()}');
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Respuestas enviadas'),
                  ));
                await _savePdf(); // Guardar PDF
                _resetForm(); // Reiniciar el formulario
              },
              child: Text('Enviar Respuestas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 87, 0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para preguntas de opción múltiple
  Widget _buildDropdownQuestion(String title, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: selectedValue,
            hint: Text('Selecciona una opción'),
            isExpanded: true,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Método para mostrar la fecha
  Widget _buildDateQuestion(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Método para pregunta de texto
  Widget _buildTextInputQuestion(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta aquí',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // Método para subir fotos
  Widget _buildPhotoQuestion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fotografía',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.photo_library),
            label: Text('Subir imagen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 87, 0),
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),

          // Visualización de imágenes seleccionadas
          _imageFiles.isEmpty
              ? Text('No se han seleccionado imágenes.')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Tres imágenes por fila
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _showImageDialog(_imageFiles[index]);
                      },
                      child: Stack(
                        children: [
                          Image.file(
                            _imageFiles[index],
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imageFiles.removeAt(index);
                                });
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Método para mostrar el nombre de usuario
  Widget _buildUserQuestion(String title, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            username,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Método para selección múltiple de piezas
  Widget _buildMultiSelectPiezaQuestion() {
    List<String> options = ['Rodillo #3456', 'Banda #5634', 'Engranaje #8756', 'Cepillo #1234'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Piezas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            hint: Text('Selecciona una pieza'),
            isExpanded: true,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null && !_selectedPiezas.contains(newValue)) {
                setState(() {
                  _selectedPiezas.add(newValue); // Agregar pieza seleccionada
                  _pieceCounts[newValue] = 1; // Inicializar contador de piezas
                });
              }
            },
          ),
          SizedBox(height: 10),
          // Visualización de piezas seleccionadas
          _selectedPiezas.isEmpty
              ? Text('No se han seleccionado piezas.')
              : Column(
                  children: _selectedPiezas.map((pieza) {
                    return ListTile(
                      title: Text(pieza),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                _pieceCounts[pieza] = (_pieceCounts[pieza] ?? 0) + 1; // Incrementar contador de piezas
                              });
                            },
                          ),
                          Text(_pieceCounts[pieza]?.toString() ?? '0'), // Mostrar contador de piezas
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (_pieceCounts[pieza] != null && _pieceCounts[pieza]! > 1) {
                                  _pieceCounts[pieza] = _pieceCounts[pieza]! - 1; // Disminuir contador de piezas
                                } else {
                                  _selectedPiezas.remove(pieza); // Eliminar pieza seleccionada
                                  _pieceCounts.remove(pieza); // Eliminar contador de piezas
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // Método para mostrar el recuadro de firma
  Widget _buildSignaturePad() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Firma',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(
              controller: _signatureController,
              height: 200,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _signatureController.clear();
                },
                child: Text('Borrar Firma'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_signatureController.isNotEmpty) {
                    final signature = await _signatureController.toPngBytes();
                    // Aquí puedes agregar funcionalidad para guardar la firma
                  }
                },
                child: Text('Guardar Firma'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 87, 0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Hechos'),
        backgroundColor: const Color.fromARGB(255, 255, 87, 0),
      ),
      drawer: _buildDrawer(context),
      body: _buildQuestionnaire(),
    );
  }
}
