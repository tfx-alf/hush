import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UDPReceiverPage extends StatefulWidget {
  const UDPReceiverPage({super.key});

  @override
  State<UDPReceiverPage> createState() => _UDPReceiverPageState();
}

class _UDPReceiverPageState extends State<UDPReceiverPage> {
  String status = "⏳ Waiting for server response...";
  bool isServerConnected = false;
  List<Device> devices = [];

  void _reciveUDP() async {
    final RawDatagramSocket socket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 15005);
    socket.broadcastEnabled = true;

    // Send discovery packet to the network
    const String message = "PHONE_CONNECTED";
    final Uint8List data = utf8.encode(message);
    final InternetAddress broadcastAddress = InternetAddress("192.168.1.146");
    const int port = 5000;

    log("🔍 Sending discovery message...");
    socket.send(data, broadcastAddress, port);

    // Listen for server responses
    log("📡 Listening for server responses...");
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram == null) return;

        final String jsonStr = utf8.decode(datagram.data);
        try {
          final response = json.decode(jsonStr);
          if (response['status'] == 'success') {
            setState(() {
              isServerConnected = true;
              status = "✅ Server connected!";
              devices = (response['devices'] as List)
                  .map((device) => Device.fromJson(device))
                  .toList();
            });
            for (final device in devices) {
              log("✅ Device Found:");
              log("ID: ${device.deviceId}");
              log("IP: ${device.ip}");
              log("Type: ${device.type}");
              log("Port: ${device.port}");
              log("-----");
            }
          }
        } catch (e) {
          log("❌ Failed to parse response: $e");
        }
      }
    });

    // Optional timeout
    // await Future.delayed(Duration(seconds: 5));
    // socket.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HUSH',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Hostile-Bird Ultimate Security Handler',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: devices.isEmpty
                    ? Text(
                        status,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isServerConnected ? Colors.green : Colors.red,
                        ),
                      )
                    : ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            child: ListTile(
                              title: Text(device.deviceId),
                              subtitle: Text(
                                "IP: ${device.ip}, Port: ${device.port}",
                              ),
                              trailing: Text(device.type),
                            ),
                          );
                        },
                      ),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    status = "⏳ Memuat ulang...";
                    isServerConnected = false;
                    devices.clear();
                  });
                  _reciveUDP();
                },
                child: const Text('Reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Device {
  final String deviceId;
  final String ip;
  final String type;
  final int port;

  Device({
    required this.deviceId,
    required this.ip,
    required this.type,
    required this.port,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      ip: json['ip'],
      type: json['type'],
      port: json['port'],
    );
  }
}
