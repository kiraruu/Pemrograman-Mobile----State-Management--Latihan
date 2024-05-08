import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Definisikan model University untuk mewakili data universitas
class University {
  late String name; // Nama universitas
  late String website; // Situs web universitas

  // Constructor
  University({required this.name, required this.website});

  // Constructor dari JSON
  University.fromJson(Map<String, dynamic> json) {
    name = json['name']; // Ambil nama universitas dari JSON
    website =
        json['web_pages'][0]; // Ambil situs web pertama dari array dalam JSON
  }
}

// Event untuk fetching data universitas
abstract class UniversityEvent {}

class FetchUniversities extends UniversityEvent {}

// State untuk menyimpan data universitas
class UniversityState {
  late List<University> universities;

  UniversityState({required this.universities});

  UniversityState.initial() {
    universities = [];
  }
}

// BLoC untuk mengelola state dan event untuk data universitas
class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc() : super(UniversityState.initial());

  Stream<UniversityState> mapEventToState(UniversityEvent event) async* {
    if (event is FetchUniversities) {
      yield await fetchUniversities();
    }
  }

  Future<UniversityState> fetchUniversities() async {
    String url =
        "http://universities.hipolabs.com/search?country=Indonesia"; // URL endpoint untuk data universitas Indonesia
    final response = await http.get(Uri.parse(url)); // Lakukan HTTP GET request

    if (response.statusCode == 200) {
      // Jika respons berhasil (status code 200),
      final List<dynamic> data = jsonDecode(response.body);
      final universitiesList =
          data.map((university) => University.fromJson(university)).toList();
      return UniversityState(universities: universitiesList);
    } else {
      // Jika respons gagal,
      throw Exception('Failed to load universities'); // Lemparkan exception
    }
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityBloc = BlocProvider.of<UniversityBloc>(context);
    universityBloc.add(FetchUniversities());

    return BlocBuilder<UniversityBloc, UniversityState>(
      builder: (context, state) {
        if (state.universities.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
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
          );
        }
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
    return BlocProvider(
      create: (context) => UniversityBloc(),
      child: MaterialApp(   
        title: 'Daftar Universitas di Indonesia',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Universitas di Indonesia'),
          ),
          body: UniversityList(),
        ),
      ),
    );
  }
}
