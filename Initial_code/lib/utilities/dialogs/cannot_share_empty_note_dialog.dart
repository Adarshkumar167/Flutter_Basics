import 'package:flutter/material.dart';
import 'package:initial/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'sharing',
      content: 'You cannot share an empty note!',
      optionsBuilder: () => {
            'OK': null,
          });
}
