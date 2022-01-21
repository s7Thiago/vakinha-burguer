import 'package:mysql1/mysql1.dart';
import 'package:vakinha_burguer_api/app/core/database/database.dart';
import 'package:vakinha_burguer_api/app/core/entities/user.dart';
import 'package:vakinha_burguer_api/app/core/exceptions/email_already_registered.dart';
import 'package:vakinha_burguer_api/app/core/helpers/cripty_helper.dart';

class UserRepository {
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
}
