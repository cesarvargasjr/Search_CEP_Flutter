// ignore_for_file: avoid_print, non_constant_identifier_names, unused_local_variable, unused_import, unrelated_type_equality_checks, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:core';
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:web_service/models/result_cep.dart';

class ViaCepService {
  static Future<ResultCep> fetchCep({String? cep}) async {
    // Declarações
    final Uri uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await http.get(uri);

    var a = jsonDecode(response.body);

    if (a["erro"] == true) {
      print('DEU ERRO NULO--- TRATAR AQUIIIII');
      final Uri uriError = Uri.parse('https://viacep.com.br/ws/93900000/json/');
      final responseError = await http.get(uriError);
      return ResultCep.fromJson(responseError.body);
    } else {
      print('BELEZA, VAI RETORNAR RESULTCEP');
      return ResultCep.fromJson(response.body);
    }
  }
}
