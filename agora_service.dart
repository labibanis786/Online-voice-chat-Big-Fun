import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../constants.dart';

class AgoraService {
  late final RtcEngine _engine;
  Future<void> initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: agoraAppId));
    await _engine.enableAudio();
  }

  Future<void> joinChannel(String channelName) async {
    await _engine.joinChannel(token: agoraToken, channelId: channelName, uid: 0, options: const ChannelMediaOptions());
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  void dispose() {
    try { _engine.release(); } catch (_) {}
  }
}