// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, deprecated_member_use, sized_box_for_whitespace, avoid_print, unused_element, unnecessary_cast, unused_import, unused_local_variable, prefer_const_literals_to_create_immutables, duplicate_ignore

import 'dart:async';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:web_service/models/result_cep.dart';
import 'package:web_service/services/via_cep_service.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Declaração Bools
  bool _loading = false;
  bool _enableField = true;
  bool _erro = true;

  // Declaração Strings
  String? _result;
  String? status = 'Por favor, informe o CEP.';
  String? cep = '';
  String? logradouro = '';
  String? complemento = '';
  String? bairro = '';
  String? localidade = '';
  String? uf = '';
  String? ibge = '';
  String? gia = '';
  String? ddd = '';
  String? siafi = '';

  // Declaração Finals
  final formKey = GlobalKey<FormState>();
  final List<Flushbar> flushBars = [];

  // Var auxiliares
  var titleSnackBar = '';
  var massageSnackBar = '';
  var comparar = '93900-000';
  var _searchCepController = TextEditingController();

  get child => null;

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Busca de CEP'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  // WIDGETS DO PROJETO

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(labelText: 'Digite o Cep'),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(60.0, 15.0, 60.0, 15.0),
      child: RaisedButton(
        onPressed: _searchCep,
        color: Colors.green,
        child: _loading
            ? _circularLoading()
            : Text(
                'Consultar',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _circularLoading() {
    return Container(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildResultForm() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.green, size: 30),
                onPressed: () {
                  _share(context);
                },
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(
                    '$status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '               ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$logradouro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$complemento',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$bairro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$localidade',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$uf',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$ddd',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '$ibge',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future _searchCep() async {
    // Variaveis de apoio
    var cep = _searchCepController.text;

    // Validações
    if (cep.isEmpty || cep == '' || cep.length > 8 || cep.length < 8) {
      if (cep.length > 8 || cep.length < 8) {
        _erro = true;
        titleSnackBar = 'Atenção!';
        massageSnackBar = 'Quantidade de caracteres incorreto.';
        showTopSnackBar(context);
      }

      if (cep.isEmpty || cep == '') {
        _erro = true;
        titleSnackBar = 'Atenção!';
        massageSnackBar = 'Digite o CEP para realizar a consultar.';
        showTopSnackBar(context);
      }

      status = '';
      cep = '';
      logradouro = '';
      complemento = '';
      bairro = '';
      localidade = '';
      uf = '';
      ibge = '';
      gia = '';
      ddd = '';
      siafi = '';
    } else {
      _searching(true);

      final resultCep = await ViaCepService.fetchCep(cep: cep);
      _result = resultCep.toJson() as String?;

      setState(() {
        // Valida retorno do JSON

        if (resultCep.cep == comparar) {
          _erro = true;
          titleSnackBar = 'Atenção!';
          massageSnackBar = 'CEP inexistente!';
          showTopSnackBar(context);

          status = '';
          cep = '';
          logradouro = '';
          complemento = '';
          bairro = '';
          localidade = '';
          uf = '';
          ibge = '';
          gia = '';
          ddd = '';
          siafi = '';
        } else {
          _erro = false;
          titleSnackBar = 'CEP válido!';
          massageSnackBar = 'Busca realizada com sucesso.';
          showTopSnackBar(context);
          status = 'Resultado da busca';
          cep = resultCep.cep;
          logradouro = resultCep.logradouro;
          complemento = resultCep.complemento;
          bairro = resultCep.bairro;
          localidade = resultCep.localidade;
          uf = resultCep.uf;
          ibge = resultCep.ibge;
          gia = resultCep.gia;
          ddd = resultCep.ddd;
          siafi = resultCep.siafi;
        }
      });
    }

    _searching(false);
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  // FlushBar

  void showTopSnackBar(BuildContext context) => show(
        context,
        Flushbar(
          icon: Icon(
            Icons.error,
            size: 40,
            color: Colors.red,
          ),
          shouldIconPulse: false,
          title: titleSnackBar,
          message: massageSnackBar,
          onTap: (_) {
            print('Clicked bar');
          },
          duration: Duration(seconds: 3),
          flushbarPosition: FlushbarPosition.TOP,
          margin: EdgeInsets.fromLTRB(8, kToolbarHeight + 8, 8, 0),
        ),
      );

  Future show(BuildContext context, Flushbar newFlushBar) async {
    await Future.wait(flushBars.map((flushBar) => flushBar.dismiss()).toList());
    flushBars.clear();

    newFlushBar.show(context);
    flushBars.add(newFlushBar);
  }

  void _share(BuildContext context) {
    dynamic cep;

    if (_erro == true) {
      titleSnackBar = 'Atenção!';
      massageSnackBar = 'Não é possível compartilhar um CEP inválido.';
      showTopSnackBar(context);
    } else if (_result != '') {
      cep = ResultCep.fromJson(_result!);
      Share.share(
        "cep: ${cep.cep}, Logradouro: ${cep.logradouro}, Complemento: ${cep.complemento},"
        "Bairro: ${cep.bairro}, Cidade: ${cep.localidade}, Uf: ${cep.uf}, Ibge: ${cep.ibge},"
        "Gia: ${cep.gia}, DDD: ${cep.ddd}, Siafi: ${cep.siafi}.",
      );
    }
  }
}
