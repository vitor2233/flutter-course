import 'dart:io';
import 'dart:async';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  //Entre chaves significa que é opcional
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _isUserEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    //Se não foi passado um contato,
    //o edited recebe um novo, se foi passado, então vai converter em map e mandar pro contact
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      //Colocar as informações nos TextField
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  ImagePicker()
                      .getImage(
                          source: ImageSource
                              .camera) //.camera vc tira a foto, .gallery vc seleciona
                      .then((file) {
                    //Usuário abriu a câmera e não tirou nenhuma foto
                    if (file == null) return;
                    //Caso não seja nulo
                    setState(() {
                      _editedContact.image = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.image != null
                          ? FileImage(File(_editedContact.image))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  _isUserEdited = true;

                  //SetState é usado para colocar o nome no AppBar
                  setState(() {
                    _editedContact.name = text;
                  });
                },
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (text) {
                  _isUserEdited = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Telefone",
                ),
                onChanged: (text) {
                  _isUserEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              //Voltar para outra tela
              //Com o Navigator.pop eu posso passar o _editedContact como parâmetro
              //Então o recContact irá receber meu _editedContact
              Navigator.pop(context, _editedContact);
            } else {
              //Colocar o foco no _nameFocus, que é o TextField name
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_isUserEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar alterações"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: [
              FlatButton(
                onPressed: () {
                  //Tirar o alerta da tela
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  //Tirar o alerta da tela, depois tirar a tela de contato
                  //Assim, irá para a tela home
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Sim"),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
