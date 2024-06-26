import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application/classes/all.dart';
import 'package:flutter_application/commonElements/responsive_padding.dart';
import 'package:flutter_application/commonElements/selectable_thumbnail_grid.dart';
import 'package:flutter_application/data/database_helper.dart';
import 'package:flutter_application/data/thumbnail.dart';
import '../../commonElements/blurred_box.dart';
import '../../commonElements/headings_title.dart';

List<Member> selectedMembers = [];
List<Member> initialMembers = [];

class EditTeamScreen extends StatefulWidget {
  const EditTeamScreen({super.key, required this.team});

  final Team team;

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  late TextEditingController teamNameController;
  late SelectableThumbnailGrid grid;

  @override
  void initState() {
    super.initState();
    teamNameController = TextEditingController(text: widget.team.getName());
    grid = SelectableThumbnailGrid(
        selectedThumbnail:
            Thumbnail.teamThumbnails.indexOf(widget.team.thumbnail),
        list: Thumbnail.teamThumbnails);
  }

  @override
  void dispose() {
    teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 232, 232, 232),
            Color.fromARGB(255, 0, 183, 255),
            Color.fromARGB(255, 0, 183, 255),
            Color.fromARGB(255, 255, 0, 115),
            Color.fromARGB(255, 255, 0, 115),
            Colors.yellow,
          ],
          stops: [0.79, 0.79, 0.865, 0.865, 0.94, 0.94],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 55),
          child: BlurredBox(
            borderRadius: BorderRadius.zero,
            sigma: 15,
            child: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(100, 0, 0, 0),
              title: Text('Modifica ${widget.team.name}'),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics()
              .applyTo(const BouncingScrollPhysics()),
          child: Container(
            margin: getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  children: [CustomHeadingTitle(titleText: "Nome")],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: BlurredBox(
                    borderRadius: BorderRadius.circular(30),
                    sigma: 15,
                    child: TextField(
                      maxLength: 50,
                      style: const TextStyle(color: Colors.white),
                      controller: teamNameController,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        filled: true,
                        fillColor: const Color.fromARGB(100, 0, 0, 0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: widget.team.name,
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 192, 192, 192)),
                      ),
                    ),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomHeadingTitle(titleText: "Membri"),
                  ],
                ),
                const SizedBox(height: 10),
                SelectableMembersList(team: widget.team),
                const SizedBox(height: 5),
                const Row(
                    children: [CustomHeadingTitle(titleText: "Copertina")]),
                grid,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.pink),
                  onPressed: () async {
                    if (selectedMembers.length < 2) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Errore'),
                          content: const Text(
                              "Il team deve essere composto da almeno due membri."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Ok'),
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      );
                      return; // Termina la funzione se non ci sono abbastanza membri
                    }
                    if (!checkIfMembersAreFree(widget.team.name)) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Errore'),
                          content: const Text(
                              "Almeno uno dei membri del team è occupato."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Ok'),
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      );
                      return; // Termina la funzione se almeno un membro è occupato
                    }
                    // Altrimenti, procedi con l'aggiornamento del team
                    await DatabaseHelper.instance.updateTeamName(
                        widget.team.getName(), teamNameController.text);
                    await DatabaseHelper.instance.updateThumbnailTeam(
                        teamNameController.text,
                        Thumbnail
                            .teamThumbnails[grid.selectedThumbnail].assetName);
                    widget.team.name = teamNameController.text;
                    widget.team.thumbnail =
                        Thumbnail.teamThumbnails[grid.selectedThumbnail];

                    for (Member member in selectedMembers) {
                      await DatabaseHelper.instance.assignTeamToMember(
                          teamNameController.text, member.code!);
                    }

                    for (Member member in await DatabaseHelper.instance
                        .getMembersByTeam(widget.team.name)) {
                      if (!selectedMembers.contains(member)) {
                        DatabaseHelper.instance.removeTeamFromMember(
                            member.code!, widget.team.name);
                      }
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      elevation: null,
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      content: Container(
                          color: const Color.fromARGB(156, 0, 0, 0),
                          child: const BlurredBox(
                              sigma: 20,
                              borderRadius: BorderRadius.zero,
                              child: Column(children: [
                                SizedBox(height: 10),
                                Text('Team modificato con successo!'),
                                SizedBox(height: 10)
                              ]))),
                    ));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 5),
                      Text("Modifica team"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool checkIfMembersAreFree(String team) {
    bool valid = true;
    for (Member member in selectedMembers) {
      if (member.mainTeam != null && member.secondaryTeam != null) {
        valid = valid &&
            (member.isFree() ||
                member.mainTeam!.name == team ||
                member.secondaryTeam!.name == team);
      }
    }

    return valid;
  }
}

class SelectableMembersList extends StatefulWidget {
  final Team? team;

  const SelectableMembersList({super.key, this.team});

  @override
  State<SelectableMembersList> createState() => _SelectableMembersListState();
}

class _SelectableMembersListState extends State<SelectableMembersList> {
  List<Member> allMembers = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadMembersByTeam();
  }

  Future<void> _loadMembers() async {
    List<Member> loadedMembers = await DatabaseHelper.instance.getMembers();
    setState(() {
      allMembers = loadedMembers;
    });
  }

  Future<void> _loadMembersByTeam() async {
    List<Member> membersTeam =
        await DatabaseHelper.instance.getMembersByTeam(widget.team!.getName());
    setState(() {
      selectedMembers = membersTeam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlurredBox(
          borderRadius: BorderRadius.circular(10),
          sigma: 15,
          child: Container(
            height: 40,
            color: const Color.fromARGB(120, 0, 0, 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide.none,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Aggiungi membri"),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: allMembers.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedMembers
                                          .contains(allMembers[index])) {
                                        selectedMembers
                                            .remove(allMembers[index]);
                                      } else {
                                        selectedMembers.add(allMembers[index]);
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.transparent),
                                        color: selectedMembers
                                                .contains(allMembers[index])
                                            ? const Color.fromARGB(
                                                255, 207, 28, 79)
                                            : const Color.fromARGB(
                                                255, 255, 255, 255)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "${allMembers[index].code}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      selectedMembers.contains(
                                                              allMembers[index])
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                            TextSpan(
                                                text:
                                                    ": ${allMembers[index].name} ${allMembers[index].surname}",
                                                style: TextStyle(
                                                    color: selectedMembers
                                                            .contains(
                                                                allMembers[
                                                                    index])
                                                        ? Colors.white
                                                        : Colors.black)),
                                            TextSpan(
                                                text:
                                                    " (${allMembers[index].role})",
                                                style: TextStyle(
                                                    color: selectedMembers
                                                            .contains(
                                                                allMembers[
                                                                    index])
                                                        ? Colors.white
                                                        : Colors.black)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Annulla',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Conferma',
                            style: TextStyle(color: Colors.pink),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      "Partecipanti al progetto",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 23,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedMembers.length,
          itemBuilder: (context, index) {
            Member member = selectedMembers[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Matricola:'),
                              Text('Nome:'),
                              Text('Cognome:'),
                              Text('Ruolo:'),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                member.getCode().toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                member.getMemberName(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                member.getMemberSurname(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                member.getMemberRole(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            selectedMembers.remove(member);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
