import 'package:flut_notes/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
