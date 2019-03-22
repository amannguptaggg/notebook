import 'package:flutter/material.dart';
import 'package:notebook/screens/notedetails.dart';
import 'dart:async';
import 'package:notebook/models/note.dart';
import 'package:notebook/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteStateList();
  }
}

class NoteStateList extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0 ;

  @override
  Widget build(BuildContext context) {

    if(noteList == null) {
      noteList = List<Note>() ;
      updateListView();

    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigationToDetail(Note('','',2),'Add New Note');
        },
        child: Icon(Icons.add_circle_outline),
        tooltip: "Add New Note",
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriority(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: textStyle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.blue,

                ),
                  onTap: () {
                    _delete(context,noteList[position]);
                  },
              ),
              onTap: () {
                navigationToDetail(this.noteList[position], 'Edit Note');
          }
              ,
            ),
          );
        });
  }

  //Returns the Priorties Colors
  Color getPriorityColor(int priority) {
    switch(priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  Icon getPriority (int priority) {
    switch(priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0 ) {
      showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigationToDetail(Note note,String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note,title);
    }));

    if(result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initilizeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

}


