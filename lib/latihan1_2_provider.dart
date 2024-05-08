import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Nama universitas
  String website; // Situs web universitas

  University({required this.name, required this.website}); // Constructor

  // Method untuk membuat objek University dari JSON
  University.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        website = json['web_pages'][0];
}

// State untuk menyimpan daftar universitas
class UniversitiesListState {
  final List<University> universities;

  UniversitiesListState(this.universities);
}

// Event untuk fetching data universitas
class FetchUniversities extends ChangeNotifier {
  UniversitiesListState _universitiesListState =
      UniversitiesListState([]); // State universitas

  UniversitiesListState get universitiesListState => _universitiesListState;

  void fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final universitiesList =
          data.map((university) => University.fromJson(university)).toList();
      _universitiesListState = UniversitiesListState(universitiesList);
      notifyListeners();
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  late FetchUniversities fetchUniversities;

  String _selectedCountry = 'Indonesia'; // Negara default yang dipilih

  @override
  void initState() {
    fetchUniversities = Provider.of<FetchUniversities>(context, listen: false);
    fetchUniversities.fetchData(_selectedCountry);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FetchUniversities>(
      builder: (context, fetchUniversities, child) {
        return Column(
          children: [
            DropdownButton<String>(
              value: _selectedCountry,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                  fetchUniversities.fetchData(_selectedCountry);
                }
              },
              items: <String>[
                'Indonesia',
                'Singapore',
                'Malaysia',
                'Thailand',
                'Vietnam'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (fetchUniversities.universitiesListState.universities.isEmpty)
              Center(
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: fetchUniversities
                      .universitiesListState.universities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(fetchUniversities
                            .universitiesListState.universities[index].name),
                        subtitle: Text(fetchUniversities
                            .universitiesListState.universities[index].website),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FetchUniversities(),
      child: MaterialApp(
        title: 'Daftar Universitas di ASEAN',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Universitas di ASEAN'),
          ),
          body: UniversityList(),
        ),
      ),
    );
  }
}
