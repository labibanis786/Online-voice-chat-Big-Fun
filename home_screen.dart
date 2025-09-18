import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/agora_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final roomController = TextEditingController();
  final roomsRef = FirebaseFirestore.instance.collection('rooms');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createRoom() async {
    final id = const Uuid().v4();
    final name = roomController.text.trim().isEmpty ? 'room-\$id' : roomController.text.trim();
    await roomsRef.doc(id).set({'name': name, 'createdAt': FieldValue.serverTimestamp()});
    roomController.clear();
  }

  Future<void> _joinRoom(String roomId) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RoomPage(roomId: roomId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Big Fan Voice Chat - Rooms'), actions: [
        IconButton(onPressed: () async { await FirebaseAuth.instance.signOut(); Navigator.pushReplacementNamed(context, '/'); }, icon: const Icon(Icons.logout))
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room name'))),
              IconButton(onPressed: _createRoom, icon: const Icon(Icons.add))
            ]),
          ),
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: roomsRef.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  return ListTile(
                    title: Text(d['name'] ?? 'Room'),
                    trailing: ElevatedButton(onPressed: () => _joinRoom(d.id), child: const Text('Join')),
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  final String roomId;
  const RoomPage({required this.roomId, super.key});
  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final AgoraService _agora;
  bool joined = false;
  int remoteUid = 0;

  @override
  void initState() {
    super.initState();
    _agora = AgoraService();
    _agora.initEngine();
  }

  @override
  void dispose() {
    _agora.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    await _agora.joinChannel(widget.roomId);
    setState(() { joined = true; });
  }

  Future<void> _leave() async {
    await _agora.leaveChannel();
    setState(() { joined = false; remoteUid = 0; });
  }

  // Simple gifting: write a gift document to Firestore
  Future<void> _sendGift() async {
    final giftsRef = FirebaseFirestore.instance.collection('gifts');
    await giftsRef.add({
      'from': FirebaseAuth.instance.currentUser?.uid,
      'toRoom': widget.roomId,
      'type': 'rose',
      'createdAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gift sent!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room: \${widget.roomId}')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(onPressed: joined ? null : _join, child: const Text('Join Voice')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: joined ? _leave : null, child: const Text('Leave')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _sendGift, child: const Text('Send Gift')),
          ]),
          const SizedBox(height: 12),
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gifts').where('toRoom', isEqualTo: widget.roomId).orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(itemCount: docs.length, itemBuilder: (context, i) {
                final d = docs[i];
                return ListTile(title: Text('Gift: \${d['type']} from \${d['from']}'));
              });
            },
          ))
        ],
      ),
    );
  }
}