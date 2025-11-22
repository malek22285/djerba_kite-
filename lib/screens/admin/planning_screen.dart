import 'package:flutter/material.dart';
import 'tabs/planning_tabs/calendrier_view.dart';
import 'tabs/planning_tabs/planning_jour_view.dart';

class PlanningScreen extends StatefulWidget {
  @override
  _PlanningScreenState createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(  // ← PAS de Scaffold!
      initialIndex: 1,
      length: 2,
      child: Column(
        children: [
          Container(
            color: Color(0xFF2a5298),
            child: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.calendar_month), text: 'Calendrier'),
                Tab(icon: Icon(Icons.today), text: 'Aujourd\'hui'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                CalendrierView(),
                PlanningJourView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}