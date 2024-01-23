import 'package:flutter/material.dart';
import 'package:initial/services/auth/auth_services.dart';
import 'package:initial/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:initial/utilities/generics/get_arguments.dart';
import 'package:initial/services/cloud/firebase_cloud_storage.dart';
import 'package:initial/services/cloud/cloud_note.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _texController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _texController = TextEditingController();
    super.initState();
  }

  void _textControllerLitener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _texController.text;
    await _notesService.updateNote(
      doucmentId: note.doucmentId,
      text: text,
    );
  }

  void _setupTextControllerListner() {
    _texController.removeListener(_textControllerLitener);
    _texController.addListener(_textControllerLitener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _texController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_texController.text.isEmpty && note != null) {
      _notesService.deleteNote(doucmentId: note.doucmentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _texController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        doucmentId: note.doucmentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _texController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _texController.text;
              if(_note == null ||text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListner();
              return TextField(
                controller: _texController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
