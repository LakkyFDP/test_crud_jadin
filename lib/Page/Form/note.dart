import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_crud_jadin/DB/database_helper.dart';
import 'package:test_crud_jadin/Model/note.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key, this.noteId});
  final int? noteId;

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final formKey = GlobalKey<FormState>();

  // Create an instance of the database helper
  DatabaseHelper noteDatabase = DatabaseHelper.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late NoteModel note;
  bool isLoading = false;
  bool isNewNote = false;

  @override
  void initState() {
    refreshNotes();
    super.initState();
  }

  // Get all notes from the database and updates the state if the noteId is not null else it sets the isNewNote to true
  refreshNotes() {
    if (widget.noteId == null) {
      setState(() {
        isNewNote = true;
      });
      return;
    }
    noteDatabase.read(widget.noteId!).then((value) {
      setState(() {
        note = value;
        titleController.text = note.title!;
        descriptionController.text = note.description!;
      });
    });
  }

  // Insert a new note into the database
  insert(NoteModel model) {
    noteDatabase.insert(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note successfully added."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note failed to save."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  // Update an existing note in the database
  update(NoteModel model) {
    noteDatabase.update(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note successfully updated."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {
        'reload': true,
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note failed to update."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  // Create a new note
  createNote() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();

      NoteModel model =
          NoteModel(titleController.text, descriptionController.text);

      if (isNewNote) {
        insert(model);
      } else {
        model.id = note.id;
        update(model);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  // Delete a note from the database and navigates back to the previous screen
  deleteNote() {
    noteDatabase.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Note successfully deleted."),
      backgroundColor: Color.fromARGB(255, 235, 108, 108),
    ));
    Navigator.pop(context);
  }

  // Validate the title field
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a title.';
    }
    return null;
  }

  popUpdeleteNote() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 0,
            title: const Row(children: [
              Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              Text('Are You Sure ?')
            ]),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Data will be permanently deleted'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () async {
                  await deleteNote();
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Note successfully deleted."),
                    backgroundColor: Color.fromARGB(255, 235, 108, 108),
                  ));
                  refreshNotes();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xffed1c24),
        elevation: 0.0,
        title: Text(
          isNewNote
              ? 'Add a note'
              : 'Edit note', // Set title to 'Add a note' if isNewNote is true, otherwise set it to 'Edit Note'
        ),
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter the title",
                      labelText: 'Title',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )),
                    ),
                    validator: validateTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Description Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter the description",
                      labelText: 'Description',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          )),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Visibility(
                    visible:
                        !isNewNote, // Set this to determine if the button should be visible
                    child: ElevatedButton(
                      onPressed: popUpdeleteNote,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Color(0xffed1c24),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: ElevatedButton(
                  onPressed: createNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffed1c24),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
