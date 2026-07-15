// This file have some ready-made demo account, so app have people to
// chat with, without register first. Delete this file when Firebase
// come and fake data source remove.
class DemoSeedUser {
  const DemoSeedUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;
}

const String demoSeedPassword = 'password123';

const List<DemoSeedUser> demoSeedUsers = [
  DemoSeedUser(
    uid: 'demo_alice',
    name: 'Alice Johnson',
    email: 'alice@example.com',
  ),
  DemoSeedUser(uid: 'demo_bob', name: 'Bob Smith', email: 'bob@example.com'),
  DemoSeedUser(
    uid: 'demo_charlie',
    name: 'Charlie Lee',
    email: 'charlie@example.com',
  ),
];
