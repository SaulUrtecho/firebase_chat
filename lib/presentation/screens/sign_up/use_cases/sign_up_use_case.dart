import 'package:either_dart/either.dart';
import 'package:todo_firestore/data/firebase/auth/firebase_auth_repository.dart';
import 'package:todo_firestore/data/firebase/models/user_model.dart';
import 'package:todo_firestore/presentation/architecture/failures.dart';
import 'package:todo_firestore/presentation/architecture/use_cases.dart';

class SignUpUseCase implements InputUseCase<UserModel, SignUpInput> {
  final FirebaseAuthRepository _firebaseAuthRepository;

  SignUpUseCase(this._firebaseAuthRepository);

  @override
  Future<Either<Failure, UserModel>> run(SignUpInput input) async {
    return _firebaseAuthRepository.createUserWithEmailAndPassword(email: input.email, password: input.password);
  }
}

/// we create a object because we need to use an email and a password
/// this object will be passed like parameter in the above function
class SignUpInput {
  final String email;
  final String password;
  const SignUpInput(this.email, this.password);
}
