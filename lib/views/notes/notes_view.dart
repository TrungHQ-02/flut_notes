import 'package:flut_notes/constants/routes.dart';
import 'package:flut_notes/enums/menu_action.dart';
import 'package:flut_notes/services/auth/auth_service.dart';
import 'package:flut_notes/services/auth/bloc/auth_bloc.dart';
import 'package:flut_notes/services/auth/bloc/auth_event.dart';
import 'package:flut_notes/services/cloud/cloud_note.dart';
import 'package:flut_notes/services/cloud/firebase_cloud_storage.dart';
import 'package:flut_notes/utilities/dialogs/logout_dialog.dart';
import 'package:flut_notes/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String get userId => AuthService.firebase().currentUser!.id;
  late final FirebaseCloudStorage _noteService;
  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
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
                      if (context.mounted) {
                        context.read<AuthBloc>().add(const AuthEventLogout());
                      }
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
      body: StreamBuilder(
        stream: _noteService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _noteService.deleteNote(
                          documentId: note.documentId);
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
      ),
    );
  }
}
