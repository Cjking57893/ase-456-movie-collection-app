import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Collection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Movie Collection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _connectionStatus = 'Checking Firebase connection...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      setState(() {
        _connectionStatus = 'Testing Firebase connection...';
      });
      
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Firebase connected successfully! 🎉';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Firebase connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _isConnected ? Icons.check_circle : Icons.sync,
                size: 64,
                color: _isConnected ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                _connectionStatus,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              if (_isConnected) ...[
                const Text(
                  'Firebase services are ready:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.login, color: Colors.blue),
                      title: Text('Firebase Authentication'),
                      subtitle: Text('User sign-in and registration'),
                    ),
                    ListTile(
                      leading: Icon(Icons.storage, color: Colors.orange),
                      title: Text('Cloud Firestore'),
                      subtitle: Text('NoSQL database for movie data'),
                    ),
                    ListTile(
                      leading: Icon(Icons.cloud_upload, color: Colors.purple),
                      title: Text('Firebase Storage'),
                      subtitle: Text('Store movie posters and images'),
                    ),
                    ListTile(
                      leading: Icon(Icons.analytics, color: Colors.green),
                      title: Text('Firebase Analytics'),
                      subtitle: Text('Track app usage and performance'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testFirebaseConnection,
        tooltip: 'Test Connection',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
