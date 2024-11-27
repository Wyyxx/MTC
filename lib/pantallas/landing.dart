import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes
import 'login.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Para manejar archivos (imágenes seleccionadas)

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final String username = "Admin"; // Variable para el nombre de usuario

  String? _selectedInstalacion;
  List<String> _selectedPiezas = []; // Lista para almacenar piezas seleccionadas
  final TextEditingController _retroalimentacionController = TextEditingController();
  List<File> _imageFiles = []; // Lista de archivos de imágenes seleccionadas

  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de hechos'),
        backgroundColor: const Color.fromARGB(255, 255, 87, 0),
      ),
      drawer: _buildDrawer(context),
      body: _buildQuestionnaire(),
    );
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
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
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
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar funcionalidad para procesar las respuestas
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Respuestas enviadas'),
                ));
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
                    return Stack(
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
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedPiezas.remove(pieza); // Eliminar pieza seleccionada
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
