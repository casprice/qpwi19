import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class ActivityPage extends StatelessWidget {
  ActivityPage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: new DailyTracker(),
    );
  }
}

/// Sample time series data type.
class TimeSeriesSteps {
  final DateTime time;
  final double steps;

  TimeSeriesSteps(this.time, this.steps);
}

class Record {
  final DateTime date;
  final int steps;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['date'] != null),
        assert(map['steps'] != null),
        date = map['date'],
        steps = map['steps'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$date:$steps>";
}

class StepCollectors {

  main() {
    var config = new File("output.txt");
    List<String> lines = config.readAsLinesSync();
    for (var l in lines) print (l);
  }
}

class DailyTracker extends StatefulWidget {
  @override
  _DailyTrackerState createState() => new _DailyTrackerState();
}

class _DailyTrackerState extends State<DailyTracker> {

  String text = "";

/*
  void main() async{
    /// Assumes the given path is a text-file-asset.
    Future<String> getFileData(String path) async {
      return await rootBundle.loadString(path);
    }

    text = await getFileData("assets/output.txt");
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: new Text('Daily Activity',
            style: TextStyle(color: Colors.white,
                fontSize: 24.0)),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('steps').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return _buildList(context, snapshot.data.documents);
        }
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.date),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text("A Title"),
          trailing: Text(record.steps.toString()),
          onTap: () => print(record),
        ),
      ),
    );

    /*
    List<String> lines = text.split("\n");
    List<String> dates = new List<String>();
    List<double> steps = new List<double>();

    for (String l in lines) {
      List<String> temp = l.split(" ");
      if ( temp.length == 3) {
        dates.add(temp[0]);
        steps.add(double.parse(temp[2]));
      }
    }

    Map<String, double> dataPair = Map.fromIterables(dates, steps);

    List<TimeSeriesSteps> data = [];

    for( String s in dataPair.keys) {
      List<String> dateSep = s.split("-");
      List<int> dateInts = new List<int>();
      for ( String s in dateSep ) {
        dateInts.add(int.parse(s));
      }
      DateTime date = new DateTime(dateInts[0], dateInts[1], dateInts[2]);
      double steps = dataPair[s];
      data.add(new TimeSeriesSteps(date, steps));
    }

    String todaySteps = "";

    if ( data.isEmpty ) {
      todaySteps = "64";
    } else {
      todaySteps = data[data.length - 1].steps.round().toString();
    }

    var series = [
      new charts.Series<TimeSeriesSteps, DateTime>(
        id: 'Steps',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (TimeSeriesSteps steps, _) => steps.time,
        measureFn: (TimeSeriesSteps steps, _) => steps.steps,
        data: data,
      )
    ];

    var chart = new charts.TimeSeriesChart(
      series,
      animate: true,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );

    var chartWidget = new Padding(
      padding: new EdgeInsets.all(10.0),
      child: new SizedBox(
        height: 245.0,
        width: 600.0,
        child: chart,
      ),
    );


    return new Scaffold(

      body: SingleChildScrollView (
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  height: 275,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        chartWidget
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  height: 160,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        ListTile(
                            title: Text(todaySteps +  " Steps",
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 50.0
                              ),
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Text('Today\'s Steps',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20.0
                              ),
                              textAlign: TextAlign.center,)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  height: 160,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                            title: Text('Today\'s Goal:',
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 50.0
                              ),
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Text('10000 Steps',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20.0
                              ),
                              textAlign: TextAlign.center,)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ); */
  }
}