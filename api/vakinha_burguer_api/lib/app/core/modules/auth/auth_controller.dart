import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:vakinha_burguer_api/app/core/entities/user.dart';
import 'package:vakinha_burguer_api/app/core/exceptions/email_already_registered.dart';
import 'package:vakinha_burguer_api/app/repositories/user_repository.dart';

part 'auth_controller.g.dart';

class AuthController {
  final _userRepository = UserRepository();

  @Route.post('/register')
  Future<Response> register(Request request) async {
    try {
      // Convertendo a request para um tipo User
      final userRequest = User.fromJson(await request.readAsString());

      // Usando o repository para salvar os dados recebidos
      _userRepository.save(userRequest);

      // Se ocorrer tudo bem retorna um status 200
      return Response(200, headers: {
        'content-Type': 'application/json',
      });
    } on EmailAlreadyRegisteredException catch (e, s) {
      print(e);
      print(s);
      return Response(
        400, // Bad Request
        body: jsonEncode({'error': 'Email já utilizado por outro usuário!'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, s) {
      // PAra qualquer outro tipo diferente de erro nesse contexto
      print(e);
      print(s);
      return Response.internalServerError(); // Status 500
    }
  }

  Router get router => _$AuthControllerRouter(this);
}


// Criação da classe de modelo 33:01 aula 2