import 'package:flutter/material.dart';
import 'package:flutter_application/classes/all.dart';
import 'package:flutter_application/commonElements/tasks_checkbox_view.dart';
import '../data/database_helper.dart';
import '../navigation/routes/edit_project_route.dart';
import 'blurred_box.dart';

Widget smallInfoContainer(Color containerColor, Color textColor, String text) {
  return Container(
      margin: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
          color: containerColor, borderRadius: BorderRadius.circular(10)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15))));
}

Widget statusCheck(Project testItem) {
  switch (testItem.getStatus()) {
    case 'Attivo':
      return smallInfoContainer(Colors.green, Colors.white, "Attivo");
    case 'Sospeso':
      return smallInfoContainer(Colors.amber, Colors.white, "Sospeso");
    case 'Archiviato':
      return smallInfoContainer(Colors.red, Colors.white, "Archiviato");
    case 'Fallito':
      return smallInfoContainer(Colors.red, Colors.white, "Fallito");
    case 'Completato':
      return smallInfoContainer(Colors.blue, Colors.white, "Completato");
    default:
      return smallInfoContainer(Colors.grey, Colors.white, "Sconosciuto");
  }
}

Widget teamCheck(Project testItem) {
  return Text(testItem.getTeam()!.getName(),
      style: const TextStyle(color: Colors.black, fontSize: 13));
}

Widget getProjectName(Project testItem) {
  return Flexible(
      child: Text(testItem.name,
          overflow: TextOverflow
              .ellipsis, //e il testo è più lungo dello spazio disponibile nel widget, verrà visualizzato un segno di ellissi ("...") alla fine
          style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)));
}

/*Widget buildEmptyAddProjectItem( context) {  return GestureDetector(onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecondRoute(),
                          ),
                        ), child: Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              width: 3, color: const Color.fromARGB(255, 255, 255, 255)),//155
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: const Center(child: Icon(Icons.add_circle_outline_sharp, size: 75, color: Colors.white,)))); }*/

Widget buildCarousel(int index, Project testItem, context) => Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: testItem.thumbnail, fit: BoxFit.cover),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //SizedBox(height: 0),
          //Align(alignment: Alignment(-0.5, 0), child: Text("Progetti recenti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statusCheck(testItem),
              IconButton(
                  onPressed: () async {
                    List<Task> tasksList = await DatabaseHelper.instance
                        .getUncompletedTasksByProjectName(testItem.name);
                    //double progress = await testItem.getProgress();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Task da completare'),
                            content: SizedBox(
                                width: double.maxFinite,
                                child: TasksCheckboxViewForHomepage(
                                    tasks: tasksList)),
                            actions: [
                              TextButton(
                                child: const Text(
                                  'Aggiungi task',
                                  style: TextStyle(color: Colors.lightBlue),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProjectScreen(
                                        project: testItem,
                                      ),
                                    ),
                                  ).then((_) => Navigator.of(context).pop());
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  'Esci',
                                  style: TextStyle(color: Colors.pink),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        });
                  },
                  icon: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                  ))
            ],
          ),
          //SizedBox(height: 3),
          Column(children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: teamCheck(testItem)))
              ],
            ),
            BlurredBox(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                sigma: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration:
                      const BoxDecoration(color: Color.fromARGB(100, 0, 0, 0)),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      getProjectName(testItem),
                    ],
                  ),
                ))
          ]), //SizedBox(height: 10)
        ],
      ),
      //child: Image.network(urlImage, height: 300)
    );
