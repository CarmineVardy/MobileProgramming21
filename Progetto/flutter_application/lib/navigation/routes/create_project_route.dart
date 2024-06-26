// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/commonElements/blurred_box.dart';
import 'package:flutter_application/commonElements/headings_title.dart';
import 'package:flutter_application/data/database_helper.dart';
import '../../commonElements/selectable_team_list.dart';
import '../../commonElements/selectable_thumbnail_grid.dart';
import '../../commonElements/tasks_checkbox_view.dart';
import '../../data/thumbnail.dart';
import 'package:flutter_application/classes/all.dart';

int selectedTeam = 0;
List<Task> cTasks = [];

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final projectNameController = TextEditingController();
  final projectDescriptionController = TextEditingController();
  TextEditingController taskInputController = TextEditingController();
  late FutureBuilder dontSetStatePlease;
  late SelectableTeamsList chips;
  late SelectableThumbnailGrid grid;

  @override
  void initState() {
    super.initState();

    grid = SelectableThumbnailGrid(
        selectedThumbnail: 0, list: Thumbnail.projectThumbnails);
    dontSetStatePlease = FutureBuilder(
        future: DatabaseHelper.instance.getTeams(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            chips = SelectableTeamsList(
              teamsList: snapshot.data!,
              selectedTeam: 0,
            );
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [chips]),
            );
          }
        });
  }

  @override
  void dispose() {
    projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TasksCheckboxView taskCheckboxList = TasksCheckboxView(tasks: cTasks);

    Project projectItem;
    return Container(
        margin: EdgeInsets.symmetric(
            vertical: 10,
            horizontal:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 20
                    : 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const SizedBox(height: 20),
          const Row(children: [CustomHeadingTitle(titleText: "Nome")]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: BlurredBox(
                borderRadius: BorderRadius.circular(30),
                sigma: 15,
                child: TextField(
                  maxLength: 50,
                  style: const TextStyle(color: Colors.white),
                  controller: projectNameController,
                  decoration: const InputDecoration(
                      counterText: '',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      filled: true,
                      fillColor: Color.fromARGB(100, 0, 0, 0),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Inserisci il nome del progetto',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 192, 192, 192))),
                )),
          ),
          const SizedBox(height: 5),
          const Row(children: [CustomHeadingTitle(titleText: "Descrizione")]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: BlurredBox(
                borderRadius: BorderRadius.circular(10),
                sigma: 15,
                child: TextField(
                  maxLength: 500,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  controller: projectDescriptionController,
                  decoration: const InputDecoration(
                      counterText: '',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      filled: true,
                      fillColor: Color.fromARGB(100, 0, 0, 0),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Questo progetto si pone l\' obiettivo di...',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 192, 192, 192))),
                )),
          ),
          const SizedBox(height: 5),
          const Row(children: [CustomHeadingTitle(titleText: "Team")]),
          const SizedBox(height: 5),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: dontSetStatePlease),
          const SizedBox(height: 5),
          const Row(children: [CustomHeadingTitle(titleText: "Copertina")]),
          grid,
          const Row(children: [CustomHeadingTitle(titleText: "Task")]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: BlurredBox(
                borderRadius: BorderRadius.circular(10),
                sigma: 15,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: taskInputController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () async {
                            if (taskInputController.text.isNotEmpty) {
                              if (!cTasks.any((task) =>
                                  task.name == taskInputController.text)) {
                                cTasks
                                    .add(Task(name: taskInputController.text));
                              }
                            }
                            taskInputController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          )),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      filled: true,
                      fillColor: const Color.fromARGB(100, 0, 0, 0),
                      border:
                          const OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Inserisci una task',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 214, 214, 214))),
                )),
          ),
          taskCheckboxList,
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.pink),
              onPressed: () async {
                List<Team> teamsList = await DatabaseHelper.instance.getTeams();
                projectNameController.text.isEmpty ||
                        projectDescriptionController.text.isEmpty ||
                        teamsList.isEmpty
                    ? showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Errore'),
                          content: const Text(
                              "Il progetto non può avere nome o descrizione vuoto.\nInoltre devono essere possibile assegnare un team al progetto."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Ok'),
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      )
                    : {
                        projectItem = Project(
                            name: projectNameController.text,
                            description: projectDescriptionController.text,
                            status: "Attivo",
                            team: teamsList[chips.selectedTeam],
                            thumbnail: Thumbnail
                                .projectThumbnails[grid.selectedThumbnail]),
                        DatabaseHelper.instance.insertProject(projectItem),
                        for (Task task in cTasks) task.setProject(projectItem),
                        for (Task task in cTasks)
                          DatabaseHelper.instance.insertTask(task),
                        projectNameController.clear(),
                        projectDescriptionController.clear(),
                        grid.selectedThumbnail = 0,
                        cTasks.clear(),
                        setState(() {}),
                        Navigator.of(context).pop(),
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          content: Container(
                              color: const Color.fromARGB(156, 0, 0, 0),
                              child: const BlurredBox(
                                  sigma: 20,
                                  borderRadius: BorderRadius.zero,
                                  child: Column(children: [
                                    SizedBox(height: 10),
                                    Text('Progetto creato con successo!'),
                                    SizedBox(height: 10)
                                  ]))),
                        ))
                      };
              },
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_task),
                SizedBox(width: 5),
                Text("Aggiungi progetto")
              ])),
          const SizedBox(height: 30)
        ]));
  }
}
