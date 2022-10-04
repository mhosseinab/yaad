import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../main.dart';
import '../models/db.dart';
import '../objectbox.g.dart';

class ReportPage extends StatelessWidget {
  final Box<ProgressData> progressBox = objectbox.store.box<ProgressData>();

  @override
  Widget build(BuildContext context) {
    final query = progressBox.query().build();
    PropertyQuery<int> pq = query.property(ProgressData_.courseID);
    pq.distinct = true;
    List<int> courses = pq.find();
    query.close();

    List<Progress> data = courses.map((item) {
      final query =
          progressBox.query(ProgressData_.courseID.equals(item)).build();
      int total = query.property(ProgressData_.total).sum();
      int done = query.property(ProgressData_.steps).sum();
      ProgressData? p = query.findFirst();
      query.close();

      return Progress(
          done: done,
          total: total,
          course: Course(id: p!.courseID, name: p.courseName));
    }).toList();

    return SafeArea(
      child: GridView.count(
        crossAxisCount: 2,
        children: data
            .map(
              (p) => Container(
                alignment: Alignment.center,
                child: CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 13.0,
                  animation: true,
                  percent: p.done / p.total,
                  center: Text(
                    "${(100.0 * p.done / p.total).toStringAsFixed(1)}%",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  footer: Text(
                    p.course.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.purple,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class Progress {
  int total;
  int done;
  Course course;
  Progress({required this.done, required this.total, required this.course});
}

class Course {
  int id;
  String name;

  Course({required this.id, required this.name});
}
