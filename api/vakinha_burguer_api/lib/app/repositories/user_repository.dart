import 'package:mysql1/mysql1.dart';
import 'package:vakinha_burguer_api/app/core/database/database.dart';
import 'package:vakinha_burguer_api/app/core/entities/user.dart';
import 'package:vakinha_burguer_api/app/core/exceptions/email_already_registered.dart';
import 'package:vakinha_burguer_api/app/core/exceptions/user_notfound_exception.dart';
import 'package:vakinha_burguer_api/app/core/helpers/cripty_helper.dart';

class UserRepository {
  // Ao chamar a rota /register insere payload com os dados do usuário no banco de dados
  Future<void> save(User user) async {
    MySqlConnection? conn;
    try {
      conn = await Database().openConnection();

      // Adicionando delay após criar a conexão
      await Future.delayed(const Duration(seconds: 1));

      // Antes é preciso verificar se o usuário já existe
      final checkRegistered = await conn.query('''
          select * from usuario where email = ?
          ''', [user.email]);

      // Se não existir, então podemos criar como um novo usuário
      if (checkRegistered.isEmpty) {
        await conn.query('''
        insert into usuario (nome, email, senha)
        values(?, ?, ?)
        ''', [
          user.name,
          user.email,
          CriptyHelper.generatedSha256Hash(user.password),
        ]);
      } else {
        throw EmailAlreadyRegisteredException();
      }
    } on MySqlException catch (e, s) {
      print(e);
      print(s);
      throw Exception();
    } finally {
      await conn?.close();
    }
  }

  Future<User> login(String email, String password) async {
    MySqlConnection? conn;
    try {
      conn = await Database().openConnection();

      // Adicionando delay após criar a conexão
      await Future.delayed(const Duration(seconds: 1));

      final result = await conn.query(
          ''' select * from usuario where email = ? and senha = ? ''',
          [email, CriptyHelper.generatedSha256Hash(password)]);

      // Se result estiver vazio quer dizer que não encontramos nenhum usuário
      if (result.isEmpty) {
        throw UserNotFoundException();
      }

      // Pegando o primeiro usuário retornado pela consulta quando ela der certo
      final userData = result.first;

      return User(
        id: userData['id'],
        name: userData['nome'],
        email: userData['email'],
        password: '',
      );
    } on Exception catch (e, s) {
      print(e);
      print(s);
      throw Exception("Erro na tentativa de login");
    } finally {
      await conn?.close();
    }
  }
}
