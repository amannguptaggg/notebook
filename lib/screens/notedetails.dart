import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:notebook/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:notebook/models/note.dart';

class NoteDetails extends StatefulWidget {

  final String appBarTitle;
  final Note note;
  NoteDetails(this.note ,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteStateDetails(this.note,this.appBarTitle);
  }
}

class NoteStateDetails extends State<NoteDetails> {

  String appBarTitle;
  Note note;

  DatabaseHelper helper = DatabaseHelper();


  static var _priorities = ['High', 'Low'];
  TextEditingController titleControler = TextEditingController();
  TextEditingController descriptionControler = TextEditingController();

  NoteStateDetails(this.note,this.appBarTitle);

  @override
  Widget build(BuildContext context) {


    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleControler.text = note.title;
    descriptionControler.text = note.description;

    return WillPopScope (
        onWillPop: () {
          moveToLastScreen();
        }
        ,child:
      Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            }),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 25.0, left: 5.0, right: 5.0, bottom: 7.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownItem,
                    child: Text(dropDownItem),
                  );
                }).toList(),
                onChanged: (valueSelectedByUser) {
                  setState(() {
                   updatePriorityAsInt(valueSelectedByUser);
                  });
                },
                style: textStyle,
                value: getPriorityAsString(note.priority),
              ),
            ),
            // Second Element
            Padding(
              padding: EdgeInsets.all(5),
              child: TextField(
                style: textStyle,
                onChanged: (value) {
                  updateTitle();
                },
                controller: titleControler,
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
              ),
            ),
            // Third Element
            Padding(
              padding: EdgeInsets.all(5),
              child: TextField(
                style: textStyle,
                onChanged: (value) {
                  updateDescription();
                },
                controller: descriptionControler,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
              ),
            ),
            //Fourth Element

            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          _save();
                        });

                      },
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Save",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          debugPrint("Delete Button Was Pressed!");
                          _delete();
                        });
                      },
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    )
    );
  }


  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

  void updatePriorityAsInt(String value) {
    switch(value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;

    }

  }
  String getPriorityAsString (int value) {
    String priority;
    switch(value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleControler.text;

  }

  void updateDescription () {
    note.description = descriptionControler.text;
  }

  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result=  await helper.insertNote(note);
    }

    if(result != 0 ) {
      _showAlertDialoug('Status','Note Saved Successfully');
    }else {
      _showAlertDialoug('Status','Problem In Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if(note.id == null) {
      _showAlertDialoug('Status', 'No Note Was Deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if(result != 0 ) {
      _showAlertDialoug('Status','Note Deleted Successfully');
    } else {
      _showAlertDialoug('Status', 'Error Occured White Deleting Note');

    }

  }

  void _showAlertDialoug (String title, String message) {
    AlertDialog alertDialog = AlertDialog(

      title: Text(title),
      content: Text(message),

    );
    showDialog(context: context,
      builder: (_) => alertDialog
    );

  }


}
