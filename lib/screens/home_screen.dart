import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movies_showcase/models/character_model/character_api_response.dart';
import 'package:movies_showcase/models/character_model/character_result.dart';
import 'package:movies_showcase/networking/network_client.dart';
import 'package:movies_showcase/networking/result.dart';
import 'package:movies_showcase/screens/details_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final mainKey = GlobalKey<ScaffoldState>();
  CharacterApiResponse _characterResponse;
  List<CharacterResult> _characters;

  @override
  void initState() {
    super.initState();
    NetworkClient().getCharacters().then((result) {
      if (result is SuccessState) {
        _characterResponse = result.value;
        setState(() {
          _characters = _characterResponse.data.results;
        });
      } else {
        mainKey.currentState.showSnackBar(SnackBar(
          content: Text(
            (result as ErrorState).msg.message,
          ),
          duration: Duration(seconds: 4),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mainKey,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/marvel_logo.jpg',
          width: 100.0,
          height: 38.0,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _characters == null
            ? Center(child: CircularProgressIndicator())
            : _characters.isEmpty
                ? Center(
                    child: Text(
                    'No Marvel Characters Available',
                    style: TextStyle(fontSize: 16.0),
                  ))
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _characters.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                      name: _characters[index].name,
                                      description:
                                          _characters[index].description,
                                      imagePath:
                                          "${_characters[index].thumbnail.path}/landscape_incredible.${_characters[index].thumbnail.extension}",
                                      marvelId: _characters[index].id,
                                    )),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                height: 200,
                                imageUrl:
                                    "${_characters[index].thumbnail.path}/landscape_incredible.${_characters[index].thumbnail.extension}",
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: CircularProgressIndicator(
                                      value: downloadProgress.progress),
                                ),
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.error)),
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black26,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                              ),
                              Positioned(
                                top: 100.0,
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(16.0),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    _characters[index].name,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
