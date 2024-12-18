import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMDb API Demo',
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OMDb Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].title),
                    subtitle: Text(_movies[index].year),
                    leading: Image.network(
                      _movies[index].poster != 'N/A'
                          ? _movies[index].poster
                          : 'https://via.placeholder.com/150',
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movie: _movies[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchMovies(String query) async {
    const apiKey = 'ddeed8a1';
    final apiUrl = 'https://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['Search'] != null) {
        final List<dynamic> movies = data['Search'];
        setState(() {
          _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
        });
      }
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

class Movie {
  final String title;
  final String year;
  final String id;
  final String poster;

  Movie({
    required this.title,
    required this.year,
    required this.id,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      id: json['imdbID'],
      poster: json['Poster'],
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _movieDetails;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    const apiKey = 'ddeed8a1';
    final url = 'https://www.omdbapi.com/?apikey=$apiKey&i=${widget.movie.id}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _movieDetails = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _movieDetails == null
              ? Center(child: Text('Erreur de chargement des détails'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: _movieDetails!['Poster'] != 'N/A'
                            ? Image.network(
                                _movieDetails!['Poster'],
                                height: 300,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 300,
                                color: Colors.grey,
                                child: Center(
                                child: Text('Aucune image disponible')),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Titre: ${_movieDetails!['Title']}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Année: ${_movieDetails!['Year']}'),
                      const SizedBox(height: 8),
                      Text('Genre: ${_movieDetails!['Genre']}'),
                      const SizedBox(height: 8),
                      Text('Réalisateur: ${_movieDetails!['Director']}'),
                      const SizedBox(height: 8),
                      Text('Acteurs: ${_movieDetails!['Actors']}'),
                      const SizedBox(height: 8),
                      Text('Résumé: ${_movieDetails!['Plot']}'),
                    
                    ],
                  ),
                ),
    );
  }
}
