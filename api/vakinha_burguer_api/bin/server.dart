import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' show load;
import 'package:vakinha_burguer_api/app/core/gerencianet/gerencianet_rest_client.dart';
import 'package:vakinha_burguer_api/app/core/modules/auth/auth_controller.dart';

// Configure routes.
final _router = Router()..mount('/auth/', AuthController().router);

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Responsável por carregar as configurações no .env
  // Chamando somente assim, o considera-se que o arquivo .env está no
  // diretório raiz do projeto e se chama ".env"
  load();

  // Fazendo um teste para atestar se o token é gerado e atribuído nas requests
  // GerencianetRestClient().auth().post('/');

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}
