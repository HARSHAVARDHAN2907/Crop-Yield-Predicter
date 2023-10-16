import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DisplayImage extends StatelessWidget {
  final String imageUrl;

  DisplayImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Pie-Chart",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: Colors.brown.shade400,
          elevation: 0,
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pexels-tetyana-kovyrina-1600139.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Container(
              child: Image.network(
                imageUrl,
                height: 400,
                width: 900,
              ),
            ),
          ),
        ]));
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectedItem = 'Tamil Nadu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profit Predictor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.brown.shade400,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pexels-tetyana-kovyrina-1600139.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 270,
                ),
                Text(
                  "Select the state you want to\n            predict Profit for",
                  style: TextStyle(
                      color: Colors.white.withGreen(219), fontSize: 25),
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButton<String>(
                  value: selectedItem,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItem = newValue!;
                    });
                    if (selectedItem == "Tamil Nadu") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TamilNadu(),
                        ),
                      );
                    }
                  },
                  items: ["Tamil Nadu", "Karnataka", "Kerala", "Andhra Pradesh"]
                      .map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                            fontSize: 25, color: Colors.white.withGreen(219)),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.transparent,
                  iconEnabledColor: Colors.white,
                  iconSize: 30,
                  underline: Container(
                    height: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TamilNadu extends StatelessWidget {
  final TextEditingController year = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Enter year",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.brown.shade400,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/pexels-tetyana-kovyrina-1600139.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Column(
            children: [
              SizedBox(
                height: 260,
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: year,
                        decoration: InputDecoration(
                          labelText: "Year",
                          filled: true,
                          fillColor: Colors.white.withGreen(219),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          int g = await _sendParam(year.text);
                          if (g == 100) {
                            try {
                              final imageUrlResponse = Uri.parse(
                                  'http://10.1.3.179:5000/get_latest_image_filename');
                              final response = await http.get(imageUrlResponse);
                              if (response.statusCode == 200) {
                                print("got");
                                final imageUrlData = jsonDecode(response.body);
                                final imageUrl =
                                    imageUrlData['latest_image_filename'];
                                print(imageUrl);
                                final url =
                                    'http://10.1.3.179:5000/get_image/$imageUrl';
                                print(imageUrl);

                                print(url);

                                // Navigate to the display image page
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DisplayImage(imageUrl: url),
                                  ),
                                );
                              }
                            } catch (e) {
                              print(
                                  "error: $e"); // Print the error for debugging
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Predict",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withGreen(219),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<int> _sendParam(String a) async {
  final url = Uri.parse("http://10.1.3.179:5000/get_send_string");
  print(a);
  try {
    final response = await http.post(
      url,
      body: {"topic": a},
    );
    if (response.statusCode == 200) {
      print("Data Sent successfully");
      return 100;
    } else {
      print("failed status");
    }
  } catch (e) {
    print("failed: $e"); // Print the error for debugging
  }
  return 0;
}
