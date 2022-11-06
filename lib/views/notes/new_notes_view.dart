import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textControler;

  @override
  void initState() {
    _notesServices = NotesServices();
    _textControler = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textControler.text;
    await _notesServices.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textControler.removeListener(_textControllerListener);
    _textControler.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesServices.getUser(email: email);
    return await _notesServices.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textControler.text.isEmpty && note != null) {
      _notesServices.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textControler.text;
    if (note != null && text.isNotEmpty) {
      await _notesServices.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setupTextControllerListener();
              return TextField(
                controller: _textControler,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing your note...'),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
