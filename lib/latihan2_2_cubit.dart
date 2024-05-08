import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
class FetchUniversities extends Cubit<UniversitiesListState> {
  FetchUniversities() : super(UniversitiesListState([]));

  void fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final universitiesList =
          data.map((university) => University.fromJson(university)).toList();
      emit(UniversitiesListState(universitiesList));
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
  String _selectedCountry = 'Indonesia'; // Negara default yang dipilih

  @override
  Widget build(BuildContext context) {
    final fetchUniversitiesCubit = context.read<FetchUniversities>();
    fetchUniversitiesCubit.fetchData(_selectedCountry);

    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedCountry,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountry = newValue;
              });
              fetchUniversitiesCubit.fetchData(_selectedCountry);
            }
          },
          items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Thailand', 'Vietnam']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        BlocBuilder<FetchUniversities, UniversitiesListState>(
          builder: (context, state) {
            if (state.universities.isEmpty) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: state.universities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(state.universities[index].name),
                        subtitle: Text(state.universities[index].website),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
