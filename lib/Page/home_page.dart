// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:test_crud_jadin/DB/database_helper.dart';
import 'package:test_crud_jadin/Model/note.dart';
import 'package:test_crud_jadin/Page/Form/note.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Create an instance of the database helper
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<NoteModel> notes = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<NoteModel> filteredNotes = []; // Maintain a list for filtered notes

  @override
  void initState() {
    refreshNotes();
    search();
    super.initState();
  }

  @override
  dispose() {
    // Close the database when no longer needed
    noteDatabase.close();
    super.dispose();
  }

  // Search methods
  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          // Perform filtering and update the filteredNotes list
          filteredNotes = notes.where((note) {
            return note.title!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                note.description!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          // Clear the filteredNotes list
          filteredNotes.clear();
        }
      });
    });
  }

  // Fetch and refresh the list of notes from the database
  refreshNotes() {
    noteDatabase.getAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  // Navigate to the NoteView screen and refresh notes afterward
  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteView(noteId: id)),
    );
    refreshNotes();
  }

  popUpdeleteNote({int? id}) async {
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
                  await noteDatabase.delete(id!);
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
    // double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xffed1c24),
        title: const Text(
          'Test CRUD Jadin',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Notes...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (isSearchTextNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      // Clear the search text and update the UI
                      searchController.clear();
                      // Reset the filteredNotes list and refresh the original notes
                      filteredNotes.clear();
                      refreshNotes();
                    },
                  ),
              ],
            ),
          ),
          // Scrollable area for displaying notes
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: notes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 250),
                            child: Text(
                              "No records to display",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              if (isSearchTextNotEmpty)
                                ...filteredNotes.map((note) {
                                  // Display filtered notes
                                  return buildNoteCard(note);
                                }).toList()
                              else
                                ...notes.map((note) {
                                  // Display original notes when not searching
                                  return buildNoteCard(note);
                                }).toList(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating action button for creating new notes
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.note_add),
        label: Text('Add Note'),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xffed1c24),
        onPressed: goToNoteDetailsView,
      ),
    );
  }

  // Helper method to build a note card
  Widget buildNoteCard(NoteModel note) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        color: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 1,
        child: GestureDetector(
          onTap: () => {
            goToNoteDetailsView(id: note.id),
          },
          child: ListTile(
            leading: const Icon(Icons.note, color: Colors.red),
            title: Text(note.title ?? ""),
            subtitle: Text(note.description ?? ""),
            trailing: Wrap(
              children: [
                // IconButton(
                //   onPressed: () => goToNoteDetailsView(id: note.id),
                //   icon: const Icon(Icons.arrow_forward_ios),
                // ),
                IconButton(
                  onPressed: () => popUpdeleteNote(id: note.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
