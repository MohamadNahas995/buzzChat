import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No status yet!'),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          final status = snapshot.data!.docs;

          return ListView.builder(
              itemBuilder: (context, index) {
                print(status[index].data()['image_url']);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              DateFormat.yMMMMd()
                                  .format((status[index].data()['createdAt']
                                          as Timestamp)
                                      .toDate())
                                  .toString(),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          title: Text(
                            status[index].data()['username'],
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: CircleAvatar(
                            child: ClipOval(
                              child: Image.network(
                                  status[index].data()['userImg']),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              status[index].data()['statusText'],
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Image.network(
                          status[index].data()['image_url'],
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: status.length);
        });
  }
}
