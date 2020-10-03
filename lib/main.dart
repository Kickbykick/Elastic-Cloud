import 'dart:convert';

import 'package:elasticcloud/elasticsearchdelegate.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/console_http_transport.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<void> mainSearchFunc() async {
    
    // final transport = ConsoleHttpTransport(Uri.parse('http://10.0.0.16:9200/'));
    // final client = elastic.Client(transport);

    // var response = await http.get('http://10.0.0.16:9200/');
    // print('Response body: ${response.body}');


    final transport = ConsoleHttpTransport(Uri.parse('https://edcfad884ba84863b44035965688d519.us-central1.gcp.cloud.es.io:9243'), basicAuth: BasicAuth("elastic", "uRkFtoiKfJSCqd4Vnw9EcDt2"));
    final client = elastic.Client(transport);
    
    final mappingJson = "{\"settings\":{\"analysis\":{\"filter\":{\"autocomplete_filter\":{\"type\":\"edge_ngram\",\"min_gram\":1,\"max_gram\":20}},\"analyzer\":{\"autocomplete\":{\"type\":\"custom\",\"tokenizer\":\"standard\",\"filter\":[\"lowercase\",\"autocomplete_filter\"]}}}},\"mappings\":{\"properties\":{\"city\":{\"type\":\"text\",\"analyzer\":\"autocomplete\",\"search_analyzer\":\"standard\"}}}}";
    Map valueMap = json.decode(mappingJson);

    await client.updateIndex("locations", valueMap);

    await transport.close();
    // await transport.close();
  }

  Future addCityFromTextField(id, city) async {
    final transport = ConsoleHttpTransport(Uri.parse('https://edcfad884ba84863b44035965688d519.us-central1.gcp.cloud.es.io:9243'), basicAuth: BasicAuth("elastic", "uRkFtoiKfJSCqd4Vnw9EcDt2"));
    final client = elastic.Client(transport);

    await client.updateDoc('locations', '_doc', id,
        {'city': city});

    await transport.close();
  }

  String id;
  String city;
  TextEditingController _idController = TextEditingController();
  TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),

            Text("Add more Cities", style: TextStyle(fontSize:20),),

            SizedBox(height: 10),

            TextField(
              controller: _idController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter ID'
              ),
              onChanged: (str){
                setState(() {
                  id = str;
                });
              },
            ),

            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Game City Name'
              ),
              onChanged: (str){
                setState(() {
                  city = str;
                });
              },
            ),

            SizedBox(height: 10),

            FlatButton(
              child: Text("Save Data", style: TextStyle(fontSize:20)),
              onPressed: () async {
                print(id);
                await addCityFromTextField(id, city);
                setState(() {
                  _idController.clear();
                  _cityController.clear();
                });
                print(id);
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await mainSearchFunc(); },
        child: Icon(Icons.search),
      ), 
    );
  }

  Future<void> _showSearch() async {
    await showSearch(
      context: context,
      delegate: ElasticSearchDelegate(),
      query: "",
    );
  }
}