import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing.dart';

// Clase principal del widget de inicio de sesión
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

// Estado del widget de inicio de sesión
class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario
  final TextEditingController _emailController = TextEditingController(); // Controlador para el campo de correo electrónico
  final TextEditingController _passwordController = TextEditingController(); // Controlador para el campo de contraseña

  // Variable para manejar la validación automática del formulario
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Variables para manejar la carga y errores
  bool _isLoading = false;
  String _errorMessage = '';

  // Método para manejar el envío del formulario
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Iniciar carga
        _errorMessage = ''; // Limpiar mensaje de error
      });

      // Credenciales predefinidas
      const String predefinedEmail = "ricardoch@martin-eng.com";
      const String predefinedPassword = "123";

      // Simular autenticación
      if (_emailController.text.trim() == predefinedEmail &&
          _passwordController.text.trim() == predefinedPassword) {
        // Login exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login exitoso!')),
        );

        // Navegar a la pantalla principal después del login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        // Error en la autenticación
        setState(() {
          _errorMessage = 'Correo electrónico o contraseña incorrectos.';
          _autovalidateMode = AutovalidateMode.always; // Habilitar validación automática
        });
      }

      setState(() {
        _isLoading = false; // Detener carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cierra la aplicación cuando se presiona el botón de retroceso del teléfono
        SystemNavigator.pop();
        return true; // Retorna true para permitir salir de la aplicación
      },
      child: Scaffold(
        body: Stack(
          children: [
            OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _buildVerticalLayout(); // Construir diseño vertical
                } else {
                  return _buildHorizontalLayout(); // Construir diseño horizontal
                }
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Versión 0.4.36',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir el diseño vertical
  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inicia sesión en MTC',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(Icons.email),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo electrónico';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : Text('Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 87, 0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Funcionalidad para restablecer contraseña (no implementada)
                  },
                  child: Text('Olvidé mi contraseña'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        return Colors.black;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir el diseño horizontal
  Widget _buildHorizontalLayout() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(Icons.email),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo electrónico';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                      : Text('Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Funcionalidad para restablecer contraseña (no implementada)
                  },
                  child: Text('Olvidé mi contraseña'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        return Colors.black;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
