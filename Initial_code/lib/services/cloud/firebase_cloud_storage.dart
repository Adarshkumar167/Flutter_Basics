import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:initial/services/cloud/cloud_storage_constants.dart';
import 'package:initial/services/cloud/cloud_storage_exceptions.dart';
import 'package:initial/services/cloud/cloud_note.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({
    required String doucmentId,
  }) async {
    try {
      await notes.doc(doucmentId).delete();
    } catch (e) {
      throw CouldNotDeleteNotesException();
    }
  }

  Future<void> updateNote({
    required String doucmentId,
    required String text,
  }) async {
    try {
      await notes.doc(doucmentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final doucment = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchedNote = await doucment.get();
    return CloudNote(
        doucmentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
