import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hush/core/shared/common_widget/dialog_widget.dart';
import 'package:hush/features/scan/data/model/url_model.dart';
import 'package:udp/udp.dart';

class UDPReceiverPage extends StatefulWidget {
  const UDPReceiverPage({super.key});

  @override
  State<UDPReceiverPage> createState() => _UDPReceiverPageState();
}

class _UDPReceiverPageState extends State<UDPReceiverPage> {
  UDP? receiver;
  List<Device> devices = [];
  String status = "⏳ Menunggu respon dari server...";
  bool hasResponse = false;
  bool isServerConnected = false;
  bool isReceiverInitialized = false;

  final serverIp = "192.168.1.173"; // Ganti sesuai IP server kamu
  final serverPort = 5000;

  @override
  void initState() {
    super.initState();
    _initializeCommunication();
  }

  void _initializeCommunication() {
    _initUDPReceiver();
    _sendInitialMessage();

    // Timeout pengecekan koneksi
    Future.delayed(const Duration(seconds: 5), () {
      if (!hasResponse) {
        setState(() {
          status = "❌ Tidak ada respon dari server ($serverIp:$serverPort)";
          isServerConnected = false;
        });
        log(status);
      }
    });
  }

  Future<void> _initUDPReceiver() async {
    if (isReceiverInitialized) {
      receiver?.close(); // Hindari multiple listener
    }

    receiver = await UDP.bind(Endpoint.any(port: Port(serverPort)));
    isReceiverInitialized = true;

    receiver!.asStream().listen((datagram) {
      if (datagram != null) {
        final message = utf8.decode(datagram.data);
        log('📩 Diterima dari ${datagram.address.address}:${datagram.port}');
        log('📨 Isi pesan: $message');

        try {
          final decoded = json.decode(message);
          if (decoded['devices'] != null) {
            final List<Device> parsedDevices = List<Device>.from(
              decoded['devices'].map((x) => Device.fromJson(x)),
            );

            log('✅ Devices parsed: $parsedDevices');

            setState(() {
              devices = parsedDevices;
              status = "✅ Terhubung ke server";
              hasResponse = true;
              isServerConnected = true;
            });
          }
        } catch (e) {
          log("❗ JSON Parse error: $e");
          setState(() {
            status = "⚠️ Gagal parsing respon dari server";
          });
        }
      }
    });
  }

  void _sendInitialMessage() async {
    try {
      final sender = await UDP.bind(Endpoint.any());
      final data = utf8.encode("flutter ping");
      final serverAddress = InternetAddress(serverIp);
      log(
        '📤 Mengirim data: ${utf8.decode(data)} ke $serverAddress:$serverPort',
      );
      await sender.send(
        data,
        Endpoint.unicast(serverAddress, port: Port(serverPort)),
      );
      sender.close();
    } catch (e) {
      log('❌ Gagal mengirim: $e');
      setState(() {
        status = "❌ Error saat mengirim data ke server: $e";
        isServerConnected = false;
      });
    }
  }

  @override
  void dispose() {
    receiver?.close();
    super.dispose();
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
              Text(
                status,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isServerConnected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    devices.isEmpty
                        ? Column(
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
                    hasResponse = false;
                    isServerConnected = false;
                    devices.clear();
                  });
                  _initializeCommunication();
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
