// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MailBot',
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 88, 2, 104)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SignIn Page'),
    );
  }
}

String val = '';
String val2 = '';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController emailcontroller;
  late TextEditingController passcontroller;
  String val = '';
  String val2 = '';
  String pass = 'naterules120';

  /*void startBackendDirectly() async {
    try {
      ProcessResult result = await Process.run(
          'python', ["C:/Users/Nathan/Documents/vs files/test.gmail.py"]);
      print('Output: ${result.stdout}');
      print('Error: ${result.stderr}');
      if (result.exitCode == 0) {
        print('Backend started successfully!');
      } else {
        print('Failed to start backend: ${result.stderr}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }*/

  @override
  void initState() {
    super.initState();
    emailcontroller = TextEditingController();
    passcontroller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Card(
            child: ElevatedButton(
                onPressed: () {
                  //startBackendDirectly();
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Emailpage()));
                  });
                },
                child: const Text("Sign In"))),
      ),
    );
  }
}

class Emailpage extends StatefulWidget {
  const Emailpage({super.key});

  @override
  State<Emailpage> createState() => _EmailpageState();
}

class _EmailpageState extends State<Emailpage> {
  late TextEditingController subcontroller;
  late TextEditingController bodcontroller;
  late TextEditingController reccontroller;
  String vali = '';
  String vali2 = '';
  String vali3 = '';
  @override
  void initState() {
    super.initState();
    subcontroller = TextEditingController();
    bodcontroller = TextEditingController();
    reccontroller = TextEditingController();
  }

  List<String>? selectedFileName; // Holds the selected file path
  List<String>? filePath; // For mobile/desktop
  List<Uint8List>? fileBytes; // For mobile/desktop

  Future<void> _pickFile() async {
    try {
      // Open file picker
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, lockParentWindow: true);

      if (result != null) {
        if (kIsWeb) {
          // On web, use `bytes` and `name`
          setState(() {
            fileBytes = result.files.map((file) => file.bytes!).toList();
            ;
            selectedFileName = result.files.map((file) => file.name).toList();
          });
        } else {
          // On mobile/desktop, use `path`
          setState(() {
            filePath = result.files.map((file) => file.path!).toList();
            selectedFileName = result.files.map((file) => file.name).toList();
          });
        }
      }
    } catch (e) {
      print("File picker error: $e");
    }
  }

  Future<void> sendEmail() async {
    final url = Uri.parse('http://192.168.100.6:5000/send-email');
    try {
      print("sending mail..");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': reccontroller.text
              .split(',')
              .map((email) => email.trim())
              .toList(),
          'subject': subcontroller.text,
          'body': bodcontroller.text,
          'file': selectedFileName
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent! ID: ${responseBody['id']}')),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: $error')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 120, 3, 141),
        title: const Text('EMAIL'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text("To: "),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'To comma separated values',
                            hintText:
                                'mailuser@gmail.com,mailuser2@gmail.com...'),
                        controller: reccontroller,
                        onChanged: (value) {
                          setState(() {
                            vali3 = reccontroller.text;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 8,
              child: Row(children: [
                Expanded(
                    child: Column(
                  children: [
                    SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: Card(
                          child: GestureDetector(
                            onTap: _pickFile,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    color:
                                        const Color.fromARGB(255, 125, 6, 146)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  selectedFileName == null ||
                                          selectedFileName!.isEmpty
                                      ? "Tap to pick a file"
                                      : selectedFileName!.join('\n'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        )),
                    ElevatedButton(
                        onPressed: sendEmail, child: const Text('Submit'))
                  ],
                )),
                Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Enter subject text',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: subcontroller,
                                    onChanged: (value) {
                                      setState(() {
                                        vali = subcontroller.text;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: bodcontroller,
                              autocorrect: true,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter body text',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  vali2 = bodcontroller.text;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    )),
              ])),
        ],
      ),
    );
  }
}
