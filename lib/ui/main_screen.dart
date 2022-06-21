import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class GifPage extends StatefulWidget {
  const GifPage({Key? key}) : super(key: key);

  @override
  _GifPageState createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {
  String _search = '';
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == '') {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=b22sbCSlhU5yv1sVj03LP3n92ndpOSpI&limit=12&rating=g'));
    } else {
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=b22sbCSlhU5yv1sVj03LP3n92ndpOSpI&q=$_search&limit=11&offset=$_offset&rating=g&lang=en'));
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then(print);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10), child: _searchLine()),
          Expanded(child: _dataDisplay()),
        ],
      ),
    );
  }

  Widget _searchLine() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(
          fontSize: 18,
          color: Colors.blueGrey,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Padding(
          padding: EdgeInsets.fromLTRB(25, 20, 20, 20),
          child: Icon(Icons.search),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xff8b8b8b)),
            gapPadding: 10),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xff8b8b8b)),
            gapPadding: 10),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xff8b8b8b)),
            gapPadding: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xff8b8b8b)),
            gapPadding: 10),
      ),
      style: const TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      onSubmitted: (text) {
        setState(() {
          _search = text;
          _offset = 0;
        });
      },
    );
  }

  Widget _dataDisplay() {
    return FutureBuilder(
        future: _getGifs(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 5.0,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Container();
              } else {
                return _createGif(context, snapshot);
              }
          }
        });
  }

  Widget _createGif(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          return FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover);
        });
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
