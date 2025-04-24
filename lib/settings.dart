import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  // Simulating saved preferences (You can replace this with actual persistent storage)
  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _darkMode);
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
    prefs.setString('language', _selectedLanguage);
    print('Preferences saved');
  }

  void _clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); // Clears all stored preferences
    print('Preferences cleared');
  }

  void _logout() {
    // Optionally, perform any cleanup or navigate to the login screen
    _clearPreferences(); // Clear preferences when logging out

    // Show a snackbar or confirmation (you can also navigate to a login screen here)
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("You have been logged out."),
    ));

    // Navigate to login screen (for example, if you have a LoginPage)
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Theme Toggle
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                _savePreferences();
              },
            ),
          ),

          // Notification Toggle
          ListTile(
            title: Text('Enable Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _savePreferences();
              },
            ),
          ),

          // Language Selector
          ListTile(
            title: Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: Icon(Icons.arrow_forward),
            onTap: () async {
              String? newLang = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Choose Language'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('English'),
                          onTap: () => Navigator.pop(context, 'English'),
                        ),
                        ListTile(
                          title: Text('Spanish'),
                          onTap: () => Navigator.pop(context, 'Spanish'),
                        ),
                        ListTile(
                          title: Text('French'),
                          onTap: () => Navigator.pop(context, 'French'),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (newLang != null) {
                setState(() {
                  _selectedLanguage = newLang;
                });
                _savePreferences();
              }
            },
          ),

          // Privacy Settings Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: Text('Two-Factor Authentication'),
            trailing: Icon(Icons.lock),
            onTap: () {
              // Navigate to two-factor authentication screen (not implemented here)
            },
          ),
          ListTile(
            title: Text('Change Password'),
            trailing: Icon(Icons.password),
            onTap: () {
              // Navigate to change password screen (not implemented here)
            },
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for the logout button
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
