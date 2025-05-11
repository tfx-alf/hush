import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:hush/core/config/theme.dart';
import 'package:hush/features/setting/presentation/screen/setting_screen.dart';

class JoystickScreen extends StatefulWidget {
  const JoystickScreen({super.key});

  @override
  State<JoystickScreen> createState() => _JoystickScreenState();
}

class _JoystickScreenState extends State<JoystickScreen> {
  late RTCPeerConnection _peerConnection;
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    initRenderers();
    _startWebRTC();
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }

  Future<void> initRenderers() async {
    await _remoteRenderer.initialize();
  }

  Future<void> _startWebRTC() async {
    // Konfigurasi ICE (biasanya pakai STUN/TURN server)
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      'optional': [],
    };

    _peerConnection = await createPeerConnection(configuration);

    // Setup remote stream
    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Buat SDP offer
    RTCSessionDescription offer = await _peerConnection.createOffer(
      offerSdpConstraints,
    );
    await _peerConnection.setLocalDescription(offer);

    // Kirim offer ke API server
    final response = await http.post(
      Uri.parse('http://192.168.1.17:5006/api/v1/offer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "camera_id": "camera01",
        "sdp": offer.sdp,
        "type": offer.type,
      }),
    );

    log('message response: $response');

    if (response.statusCode == 200) {
      final Map<String, dynamic> resData = jsonDecode(response.body);
      final answer = resData['answer'];

      // Set SDP answer dari server
      RTCSessionDescription remoteDesc = RTCSessionDescription(
        answer['sdp'],
        answer['type'],
      );
      await _peerConnection.setRemoteDescription(remoteDesc);
    } else {
      debugPrint("Failed to get SDP answer: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for the dropdown
    final List<String> ListCamera = ['Camera 1', 'Camera 2', 'Camera 3'];
    String CameraList = ListCamera[0];

    void onChanged(String? newValue) {
      if (newValue != null) {
        CameraList = newValue;
        // You can add additional logic here if needed
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Device ID 1',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: DropdownWidget(
                    CameraList: CameraList,
                    ListCamera: ListCamera,
                    onChanged: onChanged,
                  ),
                ),
                Spacer(),
                IconButton.filled(
                  onPressed: () {},
                  focusColor: greenColor,
                  highlightColor: greenColor,
                  splashColor: greenColor,
                  hoverColor: greenColor,
                  disabledColor: greenColor,
                  icon: Icon(Icons.play_arrow),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // RTCVideoView(_remoteRenderer),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '270°Yaw',
                          style: blackTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: black,
                          ),
                        ),
                        Text(
                          '283° Pitch',
                          style: blackTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  decoration: BoxDecoration(
                    color: greenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '270°Yaw',
                          style: blackTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: black,
                          ),
                        ),
                        Text(
                          '283° Pitch',
                          style: blackTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: black,
                          ),
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
    );
  }
}

class DropdownWidget extends StatelessWidget {
  final String CameraList;
  final List<String> ListCamera;
  final ValueChanged<String?> onChanged;

  const DropdownWidget({
    super.key,
    required this.CameraList,
    required this.ListCamera,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: CameraList,
      items:
          ListCamera.map(
            (type) => DropdownMenuItem<String>(value: type, child: Text(type)),
          ).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Select Cameera',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
