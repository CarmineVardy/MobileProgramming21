import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/commonElements/headings_title.dart';
import 'package:flutter_application/data/database_helper.dart';
import 'package:flutter_application/navigation/teams_page.dart';
import 'commonElements/carousel_item.dart';
import 'navigation/add_page.dart';
import 'data/project_list.dart';
import 'navigation/homepage.dart';
import 'navigation/projects_page.dart';
import './main.dart';
import 'package:flutter_application/classes/all.dart';
import './navigation/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  final screens = [
    const HomePageScreen(), //in navigation/homepage.dart
    const ProjectScreen(), //in navigation/projects_page.dart
    const AddPage(), //in navigation/add_page.dart
    const TeamScreen(), //in navigation/teams_page.dart
    const StatsPage(), //in navigation/stats_page.dart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Color.fromARGB(56, 0, 0, 0),
          ),
        ),
        body: screens[index],
        bottomNavigationBar: NavigationBarTheme(
            data: Group21App.navigationBarTheme, //in main.dart
            child: ClipRect(
                //I'm using BackdropFilter for the blurring effect
                child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20.0,
                      sigmaY: 20.0,
                    ),
                    child: Opacity(
                      //you can change the opacity to whatever suits you best
                      opacity: 1,
                      child: NavigationBar(
                        //animationDuration: Duration(seconds: 1),
                        selectedIndex: index,
                        onDestinationSelected: (index) =>
                            setState(() => this.index = index),
                        destinations: const [
                          NavigationDestination(
                              icon: Icon(Icons.home_outlined,
                                  color: Colors.white),
                              selectedIcon: Icon(Icons.home),
                              label: ''),
                          NavigationDestination(
                              icon:
                                  Icon(Icons.map_outlined, color: Colors.white),
                              selectedIcon: Icon(Icons.map),
                              label: ''),
                          NavigationDestination(
                              icon:
                                  Icon(Icons.add_outlined, color: Colors.white),
                              selectedIcon: Icon(Icons.add),
                              label: ''),
                          NavigationDestination(
                              icon: Icon(Icons.group_outlined,
                                  color: Colors.white),
                              selectedIcon: Icon(Icons.group),
                              label: ''),
                          NavigationDestination(
                              icon: Icon(Icons.add_chart_outlined,
                                  color: Colors.white),
                              selectedIcon: Icon(Icons.add_chart),
                              label: ''),
                        ],
                      ),
                    )))));
  }
}

