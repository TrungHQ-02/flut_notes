import 'package:flut_notes/constants/routes.dart';
import 'package:flut_notes/enums/menu_action.dart';
import 'package:flut_notes/services/auth/auth_service.dart';
import 'package:flut_notes/services/crud/notes_service.dart';
import 'package:flut_notes/utilities/dialogs/logout_dialog.dart';
import 'package:flut_notes/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userEmail => AuthService.firebase().currentUser!.email!;
  late final NoteService _noteService;
  @override
  void initState() {
    _noteService = NoteService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Your notes"),
            actions: [
              IconButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add),
              ),
              PopupMenuButton<MenuAction>(
                tooltip: 'Menu',
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        await AuthService.firebase().logOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      }
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: MenuAction.logout,
                      child: Text('Logout'),
                    ),
                  ];
                },
              )
            ]),
        body: FutureBuilder(
          future: _noteService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _noteService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _noteService.deleteNote(id: note.id);
                              },
                              onTap: (note) {
                                if (!context.mounted) return;
                                Navigator.of(context).pushNamed(
                                  createOrUpdateNoteRoute,
                                  arguments: note,
                                );
                              });
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
