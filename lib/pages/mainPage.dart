import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:healthchain/pages/files/uploadFilePage.dart';
import 'package:healthchain/services/auth_service.dart';
import 'package:healthchain/pages/calendar/calendar_page.dart';
import 'package:healthchain/pages/dashboard/home.dart';
import 'package:healthchain/constants/constants.dart';
import 'package:healthchain/constants/string_constants.dart';
import 'package:healthchain/routes.dart';
import 'package:healthchain/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import 'package:healthchain/pages/files/createEMRPage.dart';
import '../../models/page_data.dart';
import 'package:healthchain/pages/profile/profilePage.dart';
import 'chat/chat_home_page.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> {
  bool _initializing = true;
  List<PageData> _pageDatas = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final type = prefs.getString(FirestoreConstants.type);
    List<PageData> pages = [
      if (type == "Patient")
        PageData(
          page: Home(),
          title: 'Dashboard',
          icon: Icons.home,
        ),
      PageData(
        page: const ChatHomePage(),
        title: "Chat",
        icon: Icons.chat,
      ),
      if (type != "Pharmacist")
        PageData(
          page: const UploadFilePage(),
          title: "Upload File",
          icon: Icons.file_copy_outlined,
        ),
      PageData(
        page: const ProfilePage(),
        title: "Profile",
        icon: Icons.account_box,
      ),
    ];

    setState(() {
      _pageDatas = pages;
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> navRail = [];

    if (_initializing) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: StyleConstants.primaryColor,
          ),
        ),
      );
    }

    if (MediaQuery.of(context).size.width >= 640) {
      navRail.add(_buildNavigationRail());
    }

    Widget pageWidget = _pageDatas[_selectedIndex].page;

    if (_selectedIndex >= 0 && _selectedIndex < _pageDatas.length) {
      navRail.add(Expanded(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: pageWidget,
        ),
      ));
    } else {
      navRail.add(
        const Expanded(
          child: Center(
            child: Text('Invalid page index'),
          ),
        ),
      );
    }

    // Use a Column for small screens and a Row for larger screens
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageDatas[_selectedIndex].title),
      ),
      bottomNavigationBar:
          MediaQuery.of(context).size.width < 640 ? _buildBottomNavBar() : null,
      body: MediaQuery.of(context).size.width >= 640
          ? Row(
              mainAxisSize: MainAxisSize.max,
              children: navRail,
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: navRail,
            ),
    );
  }

  Future<void> _handleRefresh() async {
    _buildBottomNavBar();
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.indigoAccent,
      // called when one tab is selected
      onTap: (int index) {
        //_handleRefresh();
        setState(() {
          _selectedIndex = index;
        });
      },
      // bottom tab items
      items: _pageDatas
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.title,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      destinations: _pageDatas
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              label: Text(e.title),
            ),
          )
          .toList(),
    );
  }
}
