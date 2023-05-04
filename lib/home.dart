import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int totalPushUps = 0;
  final StopWatchTimer stopWatchTimer = StopWatchTimer();

  // Connecting with bluetooth

  BluetoothConnection? connection;
  String incomingData = '';

  Future<void> connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress('3C:71:BF:85:48:5A');
      Fluttertoast.showToast(msg: 'Connected to the device.');

      connection!.input!.listen((Uint8List data) {
        incomingData += ascii.decode(data);
        if (incomingData.endsWith('\n')) {
          incomingData = '';

          if (incomingData == 'Start') {
            stopWatchTimer.onStartTimer();
          } else if (incomingData == 'Stop') {
            stopWatchTimer.onStopTimer();
          } else if (incomingData == 'Up') {
            setState(() {
              totalPushUps++;
            });
          }
        }
      }).onDone(() {
        Fluttertoast.showToast(msg: 'Disconnected by remote request');
      });
    } catch (exception) {
      Fluttertoast.showToast(msg: 'Can not connect to device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;

    @override
    void dispose() async {
      super.dispose();
      await stopWatchTimer.dispose(); // Need to call dispose function.
    }

    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        title: const Text('Exhibition'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: width / 25),
            child: const Icon(Icons.notifications),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: height / 10),

            const Text('Total Time',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: height / 25),

            // Stopwatch Widget
            StreamBuilder<int>(
              stream: stopWatchTimer.rawTime,
              initialData: 0,
              builder: ((context, snapshot) {
                final value = snapshot.data;
                final displayTime = value != null
                    ? StopWatchTimer.getDisplayTime(value)
                    : "Something went wrong.";

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        displayTime,
                        style: const TextStyle(
                            fontSize: 40,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              }),
            ),

            // Pushups

            SizedBox(height: height / 10),

            const Text('Total Push-Ups',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: height / 25),

            PushUpContainer(height: height, width: width, value: totalPushUps)
          ],
        ),
      ),
    );
  }
}

class PushUpContainer extends StatelessWidget {
  const PushUpContainer(
      {super.key,
      required this.height,
      required this.width,
      required this.value});

  final double height;
  final double width;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height / 9,
      width: width / 4.5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(value.toString(),
            style: TextStyle(color: Colors.grey.shade800, fontSize: 22)),
      ),
    );
  }
}
