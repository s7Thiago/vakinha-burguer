import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:dotenv/dotenv.dart';
import 'package:vakinha_burguer_api/app/core/gerencianet/gerencianet_auth_interceptor.dart';

// Classe que customiza o adaptador do Dio para que ele passe a enviar
// os certificados de segurança em todas as requisições para a Gerencianet
class GerencianetRestClient extends DioForNative {
  static final _baseOptions = BaseOptions(
    baseUrl:
        env['GERENCIANET_PROD_BASE_URL'] ?? env['gerencianetProdBaseUrl'] ?? '',
    connectTimeout: 60000,
    receiveTimeout: 60000,
  );

  // Construtor passando o _baseOptions para o construtor nativo do Dio
  GerencianetRestClient() : super(_baseOptions) {
    // Ao instanciar este client, a função que configura os certificados de
    // segurança será chamada
    _configureCertificates();

    // Adicionando  LogInterceptor do dio ao client personalizado para que
    // os logs deste client possam ser visualizados
    interceptors.add(LogInterceptor(responseBody: true));
  }

  // Configura o rest client personalizado com interceptor para adicionar o
  // access token nas requests para Gerencianet
  GerencianetRestClient auth() {
    interceptors.add(GerencianetAuthInterceptor());
    // retorna a própria requisição para que a aplicação possa dar continuidade
    return this;
  }

  // Responsável por configurar toda a parte de certificado e da aplicação
  void _configureCertificates() {
    // Alterando adaptador http padrão do Dio para um outro instalado via lib
    httpClientAdapter = Http2Adapter(ConnectionManager(
      // Este método será invocado quando o clientAdapter for criado
      // neste momento o certificado é configurado
      onClientCreate: (uri, config) {
        final pathCRT = env['GERENCIANET_PROD_CERTIFICADO_CRT'] ??
            env['gerencianetProdCertificadoCRT'] ??
            '';
        final pathKEY = env['GERENCIANET_PROD_CERTIFICADO_KEY'] ??
            env['gerencianetProdCertificadoKEY'] ??
            '';

        // Referenciando o diretório raiz da aplicação
        final root = Directory.current.path;

        // criando securityContest que confia no certificado que o root acima tiver
        final securityContext = SecurityContext(withTrustedRoots: true);

        // Dizendo onde estão os certificados no contexto de segurança
        // que serão enviados em todas as requisições
        securityContext.useCertificateChain('$root/$pathCRT');
        securityContext.usePrivateKey('$root/$pathKEY');

        // Atribuindo o security context personalizado ao config
        config.context = securityContext;
      },
    ));
  }
}
