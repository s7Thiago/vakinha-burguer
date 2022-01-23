import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:vakinha_burguer_api/app/core/gerencianet/gerencianet_rest_client.dart';

// Interceptor responsável pela parte de autenticação das requests
// Aqui é feita a autenticação via passagem de token de acesso nas requests
class GerencianetAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Em todas as requisições é feito o acesso ao login para pegar o token de acesso
    final accessToken = await _login();

    // Após receber o token, insere na requisição interceptada
    options.headers.addAll({
      'authorization': 'Bearer $accessToken',
      'content-type': 'application/json',
    });

    // Evitando problemas com o content type: setando também fora do addAll
    options.contentType = 'application/json';

    // Delegando a continuidade do processo para a aplicação
    handler.next(options);
  }

  Future<String> _login() async {
    // Mesmo no login, é preciso enviar os certificados para a gerencia net. Por
    // isso é preciso instanciar o rest client personalizado que passa o mesmo
    final client = GerencianetRestClient();

    // Adicionando os headers requeridos segundo a documentação da gerencianet
    final headers = {
      // 'authorization': 'Basic $_getAuthorization()',
      'authorization': 'Basic ${_getAuthorization()}',
      'content-type': 'application/json',
    };

    // Criando a resposta requisitando o respectivo endpoint de token da Gerencianet
    final result = await client.post(
      '/oauth/token',
      data: {
        'grant_type': 'client_credentials',
      },
      options: Options(
        headers: headers,
        contentType: 'application/json',
      ),
    );

    // Se todos os passos acima derem certo, o token de acesso é retornado
    return result.data['access_token'];
  }

  // Usa o clientId e o clientSecret da gerencianet especificados no .env e concatena
  // em algumas estruturas para gerar o token de acesso
  String _getAuthorization() {
    final clientId =
        env['GERENCIANET_CLIENT_ID'] ?? env['gerencianetClientId'] ?? '';
    final clientSecret = env['GERENCIANET_CLIENT_SECRET'] ??
        env['gerencianetClientSecret'] ??
        '';

    // Estratégia para criar o token: juntar os dois secrets separados por ':' e
    // depois transformar em base64
    final authBytes = utf8.encode('$clientId:$clientSecret');

    return base64Encode(authBytes);
  }
}
