import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'API Data Fetch Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Corrected the type of _fetchedData to match the return type of _fetchData
  late Future<List<Map<String, dynamic>>> _fetchedData;

  Future<List<Map<String, dynamic>>> _fetchData() async {
    final response = await http.get(Uri.parse('https://restaurantbackend.fly.dev/dish'));
    if (response.statusCode == 200) {
      // Decode the response body explicitly using UTF-8
      final String decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> decodedData = json.decode(decodedBody);
      return decodedData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchedData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var dish = snapshot.data![index];
                return ListTile(
                  title: Text(dish['dish_name'] ?? 'Unknown Dish'),
                  subtitle: Text('Price: \$${dish['price'].toString()}'),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

