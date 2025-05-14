import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:hush/core/config/theme.dart';
import 'package:hush/features/setting/presentation/screen/setting_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/model/camera_model.dart';

class JoystickScreen extends StatefulWidget {
  const JoystickScreen({super.key});

  @override
  State<JoystickScreen> createState() => _JoystickScreenState();
}

class _JoystickScreenState extends State<JoystickScreen> {
  late RTCPeerConnection _peerConnection;
  final _remoteRenderer = RTCVideoRenderer();
  List<Camera> _cameraList = [];
  Camera? _selectedCamera;
  late WebSocketChannel channel;
  bool _isWebRTCStarted = false;
  bool light = true;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _fetchCameraList();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.146:8080/api/v1/wsdata'),
    );
    log('message channel: $channel');
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _peerConnection.close();
    channel.sink.close();

    log('message peerConnection closed: ${_peerConnection.connectionState}');
    log('message remoteRenderer disposed: $_remoteRenderer');
    super.dispose();
  }

  Future<void> initRenderers() async {
    await _remoteRenderer.initialize();
  }

  Future<void> _fetchCameraList() async {
    final response = await http.get(
      Uri.parse('http://local.abarobotics.com/computer-vision/api/camera'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List camerasJson = data['date'];

      setState(() {
        _cameraList = camerasJson.map((json) => Camera.fromJson(json)).toList();
        _selectedCamera = _cameraList.isNotEmpty ? _cameraList.first : null;
      });
    } else {
      log('Failed to load camera list: ${response.body}');
    }
  }

  Future<void> _startWebRTC() async {
    if (_selectedCamera == null) {
      log('No camera selected. Please select a camera first.');
      setState(() {
        _isWebRTCStarted = false;
      });
      return;
    }

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

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    RTCSessionDescription offer = await _peerConnection.createOffer(
      offerSdpConstraints,
    );
    await _peerConnection.setLocalDescription(offer);

    final response = await http.post(
      Uri.parse('http://192.168.1.17:5006/api/v1/offer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "camera_id": _selectedCamera!.code,
        "sdp": offer.sdp,
        "type": offer.type,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> resData = jsonDecode(response.body);
      final answer = resData['answer'];

      RTCSessionDescription remoteDesc = RTCSessionDescription(
        answer['sdp'],
        answer['type'],
      );

      await _peerConnection.setRemoteDescription(remoteDesc);
      setState(() {
        _isWebRTCStarted = true;
      });
    } else {
      log("Failed to get SDP answer: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: DropdownButton<Camera>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(24),
                      isDense: false,
                      hint: const Text('Select a Camera'),
                      value:
                          _cameraList.contains(_selectedCamera)
                              ? _selectedCamera
                              : null,
                      items:
                          _cameraList.isNotEmpty
                              ? _cameraList
                                  .map(
                                    (camera) => DropdownMenuItem(
                                      value: camera,
                                      child: Text(camera.code),
                                    ),
                                  )
                                  .toList()
                              : [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No cameras available'),
                                ),
                              ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _isWebRTCStarted = true;
                            _selectedCamera = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: _startWebRTC,
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                      color: greenColor,
                    ),
                    child: Center(
                      child: Icon(Icons.play_arrow, color: whiteColor),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 200.h,
              child:
                  _isWebRTCStarted
                      ? RTCVideoView(
                        _remoteRenderer,
                        filterQuality: FilterQuality.low,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                        mirror: false,
                      )
                      : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                          color: greyColor,
                        ),
                        child: const Center(
                          child: Text(
                            'No camera selected. Please select a camera first.',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = jsonDecode(snapshot.data as String);
                      final yaw = data['yaw'] ?? 'N/A';
                      final pitch = data['pitch'] ?? 'N/A';

                      return Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$yaw° Yaw',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: black,
                                ),
                              ),
                              Text(
                                '$pitch° Pitch',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waiting for server response...',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
                Spacer(),
                Switch(
                  value: light,

                  activeColor: greenColor,
                  onChanged: (bool value) {
                    setState(() {
                      light = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 50.h),
            JoystickCustomizationExample(),
          ],
        ),
      ),
    );
  }
}

class JoystickCustomizationExample extends StatefulWidget {
  const JoystickCustomizationExample({super.key});

  @override
  State<JoystickCustomizationExample> createState() =>
      _JoystickCustomizationExampleState();
}

class _JoystickCustomizationExampleState
    extends State<JoystickCustomizationExample> {
  bool drawArrows = true;
  bool includeInitialAnimation = true;
  bool enableArrowAnimation = true;
  bool isBlueJoystick = false;
  bool withOuterCircle = true;
  Key key = UniqueKey();

  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.146:8080/api/v1/wsdata'),
    );
    log('message channel: $channel');
  }

  void sendJoystickData(double pitch, double yaw) {
    final Map<String, dynamic> data = {
      'pitch': pitch,
      'yaw': yaw,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    channel.sink.add(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, 0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Joystick(
                includeInitialAnimation: includeInitialAnimation,

                key: key,
                base: JoystickBase(
                  decoration: JoystickBaseDecoration(
                    color: greenColor,
                    drawArrows: drawArrows,
                    drawOuterCircle: withOuterCircle,
                    drawMiddleCircle: true,

                    drawInnerCircle: false,
                    innerCircleColor: whiteColor,
                  ),
                  arrowsDecoration: JoystickArrowsDecoration(
                    color: whiteColor,
                    enableAnimation: enableArrowAnimation,
                  ),
                ),
                stick: JoystickStick(
                  decoration: JoystickStickDecoration(
                    color: const Color.fromARGB(255, 0, 160, 5),
                  ),
                ),
                listener: (details) {
                  final double pitch = details.y; // y = pitch (naik/turun)
                  log('message pitch: $pitch');
                  final double yaw = details.x; // x = yaw (kanan/kiri)
                  log('message yaw: $yaw');
                  sendJoystickData(pitch, yaw);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
