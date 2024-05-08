import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Nama universitas
  String website; // Situs web universitas

  // Constructor
  University({required this.name, required this.website});

  // Constructor dari JSON
  University.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        website = json['web_pages'][0];
}

// Definisikan model UniversitiesList untuk menyimpan daftar universitas
class UniversitiesList {
  List<University> universities = []; // List universitas

  // Constructor untuk membuat objek UniversitiesList dari JSON
  UniversitiesList.fromJson(List<dynamic> json)
      : universities =
            json.map((university) => University.fromJson(university)).toList();
}

void main() {
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UniversityProvider(),
      child: MaterialApp(
        title: 'Daftar Universitas di Indonesia', // Judul aplikasi
        home: Scaffold(
          appBar: AppBar(
            title:
                const Text('Daftar Universitas di Indonesia'), // Judul AppBar
          ),
          body: UniversityList(),
        ),
      ),
    );
  }
}

class UniversityProvider extends ChangeNotifier {
  late UniversitiesList _universitiesList;

  Future<void> fetchData() async {
    String url =
        "http://universities.hipolabs.com/search?country=Indonesia"; // URL endpoint untuk data universitas Indonesia
    final response = await http.get(Uri.parse(url)); // Lakukan HTTP GET request

    if (response.statusCode == 200) {
      // Jika respons berhasil (status code 200),
      _universitiesList = UniversitiesList.fromJson(jsonDecode(response.body));
      // Parse respons JSON dan buat objek UniversitiesList
    } else {
      // Jika respons gagal,
      throw Exception('Failed to load universities'); // Lemparkan exception
    }
    notifyListeners();
  }

  UniversitiesList get universitiesList => _universitiesList;
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityProvider =
        Provider.of<UniversityProvider>(context, listen: false);
    universityProvider.fetchData();

    return Consumer<UniversityProvider>(
      builder: (context, universityProvider, child) {
        if (universityProvider.universitiesList.universities.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            itemCount: universityProvider.universitiesList.universities.length,
            itemBuilder: (context, index) {
              return Card(
                // Widget Card untuk setiap item universitas
                elevation: 3, // Tingkat elevasi bayangan
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                // Margin dari Card
                child: ListTile(
                  // Widget ListTile sebagai isi dari Card
                  title: Text(universityProvider.universitiesList
                      .universities[index].name), // Judul universitas
                  subtitle: Text(universityProvider
                      .universitiesList.universities[index].website),
                  // Subjudul situs web universitas
                ),
              );
            },
          );
        }
      },
    );
  }
}
