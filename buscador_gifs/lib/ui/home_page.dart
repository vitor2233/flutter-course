import 'dart:convert';
import 'dart:async';
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    //Se search for igual a null, vamos fazer a pesquisa dos trendings
    //Se não, vamos pesquisar
    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=mJ82RxBQ3uUx0FZ7Vy3eA4CO44M8vEJN&limit=20&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=mJ82RxBQ3uUx0FZ7Vy3eA4CO44M8vEJN&q=$_search&limit=19&offset=$_offset&rating=g&lang=en");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif",
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquisar",
                labelStyle: TextStyle(color: Colors.white),
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(20.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              //Texto que o usuário digita
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  //Começar com offset 0 pra carregar os primeiros itens
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        //Circulo para ficar carregando na cor branba
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        //Largura do circulo q fica girando
                        strokeWidth: 5.0,
                      ),
                    );
                    break;
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      //20 gifs retornados
      return data.length;
    } else {
      //19 gifs q vem no search +1 (para mostrar mais)
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      //Como os itens vão ser organizados
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //Quantos itens na horizonal?
        crossAxisCount: 2,
        //Espaçamento entre os itens na horizontal
        crossAxisSpacing: 10.0,
        //Espaçamento entre os itens na vertical
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      //Função que vai retornar o Widgwt pra colocar em cada posição
      itemBuilder: (context, index) {
        //Se eu não estiver pesquisando, ou se este não é o último item
        if (_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data["data"][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
            child: FadeInImage.memoryNetwork(
              //Imagem aparecer mais suave
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          );
        else
          //É o último item
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
      },
    );
  }
}
