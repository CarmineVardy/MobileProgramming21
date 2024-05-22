import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'project_items.dart';
import 'package:css_colors/css_colors.dart';

Widget smallInfoContainer(Color containerColor, Color textColor, String text, LinearGradient? gradient) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          gradient: gradient,
          color: containerColor, borderRadius: BorderRadius.circular(10)) ,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15))));
}

Widget statusCheck(ProjectItem testItem) {
  switch (testItem.status) {
              case 'Attivo':
                return smallInfoContainer(Colors.green, Colors.white, "Attivo", null);
              case 'Sospeso':
                return smallInfoContainer(Colors.amber, Colors.white, "Sospeso", null);
              case 'Archiviato':
                return smallInfoContainer(Colors.red, Colors.white, "Archiviato", null);
              case 'Fallito':
                return smallInfoContainer(Colors.red, Colors.white, "Fallito", null);
              case 'Completato':
                LinearGradient gradient = const LinearGradient(
          colors: [
            Color.fromARGB(255, 232, 232, 232),
            Color.fromARGB(255, 0, 183, 255),
            Color.fromARGB(255, 0, 183, 255),
            Color.fromARGB(255, 255, 0, 115),
            Color.fromARGB(255, 255, 0, 115),
            Colors.yellow
          ],
          stops: [0.7, 0.7, 0.80, 0.80, 0.90, 0.90],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
                return smallInfoContainer(Colors.red, Colors.black, "Completato", gradient);
              default:
                return smallInfoContainer(Colors.grey, Colors.white, "Sconosciuto", null);
            }
          }


Widget teamCheck(ProjectItem testItem) {
  return Text(testItem.team.teamName,
      style: const TextStyle(color: Colors.black, fontSize: 13));
}

Widget getProjectName(ProjectItem testItem) {
  return Flexible(child: Container(child: Text(testItem.name,
  overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white))));
}

Widget buildCarousel(int index, ProjectItem testItem) => Container(
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
            children: [
              const SizedBox(width: 15),
              statusCheck(testItem),
            ],
          ),
          //SizedBox(height: 3),
          Column(
            children: [ Row(
              children: [
                const SizedBox(width: 12),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: teamCheck(testItem)))
              ],
            ),
          

          Container(
            height: 45,
            alignment: Alignment.bottomLeft,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    //Color.fromARGB(151, 0, 0, 0),
                    Color.fromARGB(173, 0, 0, 0),
                    Color.fromARGB(203, 0, 0, 0)
                  ],
                  stops: [0.1, 0.5, 0.9],
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              children: [
                const SizedBox(
                  width: 15,
                  height: 45,
                ),
                getProjectName(testItem),
              ],
            ),
          )]), //SizedBox(height: 10)
        ],
      ),
      //child: Image.network(urlImage, height: 300)
    );