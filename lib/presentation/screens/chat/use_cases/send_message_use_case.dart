import 'package:either_dart/either.dart';
import 'package:todo_firestore/data/firebase/firestore/firebase_firestore_repository.dart';
import 'package:todo_firestore/data/firebase/models/message_model.dart';
import 'package:todo_firestore/presentation/architecture/failures.dart';
import 'package:todo_firestore/presentation/architecture/use_cases.dart';

class SendMessageUseCase implements InputUseCase<void, MessageModel> {
  final FirebaseFirestoreRepository _firebaseFirestoreRepository;

  SendMessageUseCase(this._firebaseFirestoreRepository);

  @override
  Future<Either<Failure, void>> run(MessageModel input) async {
    return _firebaseFirestoreRepository.saveMessage(input);
  }
}
