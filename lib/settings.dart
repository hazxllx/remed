//settings
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = 'Current Username'; // Example initial username
  String password = '********'; // Example initial password
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load username from Firestore and set the controller
  void loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Load the username from Firestore
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          username = snapshot['username'];
          usernameController.text = username;
        });
      }
    }
  }

  // Update username in Firestore
  void updateUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'username': usernameController.text,
      });
      setState(() {
        username = usernameController.text;
      });
    }
  }

  // Update password using Firebase Authentication
  void updatePassword() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String newPassword = passwordController.text;
      try {
        await user.updatePassword(newPassword);
        await _auth.currentUser?.reload(); // Reload the current user after password change
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password updated successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating password")));
      }
    }
  }

  // Logout functionality
  void logout() async {
    await _auth.signOut();
    Navigator.pop(context); // Navigate back to the login screen
  }

  // Delete the user's account from Firebase and Firestore
  void deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete the user's document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete the user's account from Firebase Authentication
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account deleted successfully")));
        Navigator.pop(context); // Navigate back to the login screen after account deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting account")));
      }
    }
  }

  // Show confirmation dialog for account deletion
  void confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                deleteAccount();
                Navigator.of(context).pop(); // Close the dialog after action
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.red, // Customize the app bar color as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Account Info Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Account Info'),
                subtitle: Text('Edit your personal and delivery info'),
                onTap: () {
                  // Add navigation or functionality here if needed
                },
              ),
            ),

            // Medicine Alerts Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Medicine Alerts'),
                subtitle: Text('Configure how your alerts are received'),
                onTap: () {
                  // Add functionality for medicine alerts if needed
                },
              ),
            ),

            // My Inventory Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.medical_services),
                title: Text('My Inventory'),
                subtitle: Text('Update medicines and inventories'),
                onTap: () {
                  // Add functionality for inventory management if needed
                },
              ),
            ),

            // Security & Data Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.security),
                title: Text('Security & Data'),
                subtitle: Text('Manage all of your personal information'),
                onTap: () {
                  // Add functionality for security & data if needed
                },
              ),
            ),

            // Username Change Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Change Username'),
                subtitle: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(hintText: 'Enter new username'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: updateUsername,
                ),
              ),
            ),

            // Password Change Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                subtitle: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Enter new password'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: updatePassword,
                ),
              ),
            ),

            // Logout Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: logout,
              ),
            ),

            // Delete Account Section
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Account'),
                onTap: confirmDeleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
