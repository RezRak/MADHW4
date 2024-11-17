import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MessageBoardApp());
}

class MessageBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Board App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to LoginScreen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your splash screen here
      body: Center(
        child: Text(
          'Welcome to Message Board App',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  bool isLoading = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      // Start loading
      setState(() {
        isLoading = true;
      });

      try {
        // Sign in with Firebase Authentication
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // Navigate to HomeScreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } on FirebaseAuthException catch (e) {
        // Show error message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
      } finally {
        // Stop loading
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void navigateToRegister() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => RegistrationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Login'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter email' : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (val) => password = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter password' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        child: Text('Login'),
                      ),
                      TextButton(
                        onPressed: navigateToRegister,
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// Registration Screen
class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '',
      password = '',
      firstName = '',
      lastName = '',
      role = '';
  bool isLoading = false;

  void register() async {
    if (_formKey.currentState!.validate()) {
      // Start loading
      setState(() {
        isLoading = true;
      });

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Store additional user information in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'registrationDate': FieldValue.serverTimestamp(),
        });

        // Navigate to HomeScreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } on FirebaseAuthException catch (e) {
        // Show error message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
      } finally {
        // Stop loading
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Register'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator()
              : Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'First Name'),
                        onChanged: (val) => firstName = val,
                        validator: (val) => val!.isEmpty
                            ? 'Please enter first name'
                            : null,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Last Name'),
                        onChanged: (val) => lastName = val,
                        validator: (val) => val!.isEmpty
                            ? 'Please enter last name'
                            : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Role'),
                        onChanged: (val) => role = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter role' : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter email' : null,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onChanged: (val) => password = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter password' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: register,
                        child: Text('Register'),
                      ),
                      TextButton(
                        onPressed: navigateToLogin,
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  // Hardcoded list of message boards
  final List<Map<String, String>> messageBoards = [
    {'name': 'General Discussion', 'icon': 'assets/general.png'},
    {'name': 'Announcements', 'icon': 'assets/announcements.png'},
    {'name': 'Random Chat', 'icon': 'assets/random.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Boards'),
      ),
      drawer: NavigationDrawer(),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          final board = messageBoards[index];
          return ListTile(
            leading: Icon(Icons.message),
            title: Text(board['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(boardName: board['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  final String boardName;

  ChatScreen({required this.boardName});

  @override
  _ChatScreenState createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'boardName': widget.boardName,
        'message': _messageController.text.trim(),
        'username': currentUser?.email ?? 'Anonymous',
        'datetime': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('boardName', isEqualTo: widget.boardName)
        .orderBy('datetime', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text(
                          '${message['username']} • ${message['datetime'] != null ? (message['datetime'] as Timestamp).toDate() : ''}'),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        InputDecoration(hintText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String firstName = '', lastName = '', role = '';
  bool isLoading = false;

  void loadUserData() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    setState(() {
      firstName = doc['firstName'];
      lastName = doc['lastName'];
      role = doc['role'];
      isLoading = false;
    });
  }

  void updateUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Profile'), automaticallyImplyLeading: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: firstName,
                        decoration:
                            InputDecoration(labelText: 'First Name'),
                        onChanged: (val) => firstName = val,
                        validator: (val) => val!.isEmpty
                            ? 'Please enter first name'
                            : null,
                      ),
                      TextFormField(
                        initialValue: lastName,
                        decoration:
                            InputDecoration(labelText: 'Last Name'),
                        onChanged: (val) => lastName = val,
                        validator: (val) => val!.isEmpty
                            ? 'Please enter last name'
                            : null,
                      ),
                      TextFormField(
                        initialValue: role,
                        decoration: InputDecoration(labelText: 'Role'),
                        onChanged: (val) => role = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter role' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updateUserData,
                        child: Text('Update Profile'),
                      ),
                    ],
                  )),
            ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false);
  }

  void changePassword(BuildContext context) {
    // Implement change password functionality
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Change Password functionality not implemented.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Settings'), automaticallyImplyLeading: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => changePassword(context),
              child: Text('Change Password'),
            ),
            ElevatedButton(
              onPressed: () => logout(context),
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigation Drawer
class NavigationDrawer extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.email ?? 'Guest'),
            accountEmail: Text(currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Message Boards'),
            onTap: () => navigateTo(context, HomeScreen()),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          ),
        ],
      ),
    );
  }
}