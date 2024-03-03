import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/firestore_constants.dart';
import '../../providers/chat_home_provider.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name = "";

  _HomeState() {
    getName().then((value) => setState(() {
          name = value;
        }));
  }

  Future<String> getLocalStorage(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("userId: ${prefs.getString("id")}");
    String userId = prefs.getString(type) ?? "";
    return userId;
  }

  Future<String> getName() async {
    String nickname = await getLocalStorage(FirestoreConstants.name);
    return nickname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          floating: true,
          pinned: true,
          snap: false,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello ${name ?? ''}!",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Find Your Specialist",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: const SizedBox(
                  width: double.infinity, height: 50, child: HeaderSearchBar()),
            ),
          ),
        ),
        // Other Sliver Widgets
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 30),
              const AdBoard(),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              // Wrap PopularDoctor with Container or SizedBox
            ]),
          ),
        ),
      ],
    ));
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            size: 30,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_month,
            size: 30,
          ),
          label: "Calendar",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.chat,
            size: 30,
          ),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_box,
            size: 30,
          ),
          label: "Profile",
        )
      ],
      unselectedItemColor: Colors.grey.shade500,
      selectedItemColor: Colors.blue.shade800,
      showUnselectedLabels: true,
      enableFeedback: false,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

class PopularDoctor extends StatelessWidget {
  const PopularDoctor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          height: 50,
          color: Colors.amber[600],
          child: const Center(child: Text('Entry A')),
        ),
        Container(
          height: 50,
          color: Colors.amber[500],
          child: const Center(child: Text('Entry B')),
        ),
        Container(
          height: 50,
          color: Colors.amber[100],
          child: const Center(child: Text('Entry C')),
        ),
      ],
    );
  }
}

class AdBoard extends StatelessWidget {
  const AdBoard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: const DecorationImage(
              image: AssetImage('assets/background1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: const DecorationImage(
              image: AssetImage('assets/background2.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: const DecorationImage(
              image: AssetImage('assets/background3.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }
}

class Services extends StatelessWidget {
  const Services({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            IconButton(
              onPressed: () => {print("press")},
              icon: Icon(
                Icons.account_box,
                color: Colors.lightBlue.shade400,
                size: 50,
              ),
            )
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () => {print("press")},
              icon: Icon(
                Icons.medical_information,
                color: Colors.orangeAccent.shade400,
                size: 50,
              ),
            )
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () => {print("press")},
              icon: Icon(
                Icons.add_chart,
                color: Colors.lightGreen.shade400,
                size: 50,
              ),
            )
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () => {print("press")},
              icon: Icon(
                Icons.account_balance_wallet,
                color: Colors.redAccent.shade400,
                size: 50,
              ),
            )
          ],
        ),
      ],
    );
  }
}

class HeaderSearchBar extends StatefulWidget {
  const HeaderSearchBar({super.key});
  @override
  State<HeaderSearchBar> createState() => _HeaderSearchBarState();
}

class _HeaderSearchBarState extends State<HeaderSearchBar> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getUser(String name) async {
    // Assuming 'users' is the name of your collection
    QuerySnapshot<Map<String, dynamic>> userSnapshot;
    if(name.isEmpty){
      userSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .get();
    }else{
      userSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.name, isGreaterThanOrEqualTo: name)
          .where(FirestoreConstants.name, isLessThan: '${name}z')
          .get();
    }
    return userSnapshot;
  }
  
  @override
  Widget build(BuildContext context) {

    return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            hintText: "Search Doctor/Pharmacist",
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            trailing: <Widget>[
              Tooltip(
                message: 'Search',
                child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    print("search");
                  },
                ),
              )
            ],
          );
        }, suggestionsBuilder:
        (BuildContext context, SearchController controller) async {
          List<Map<String, dynamic>> userData = [];
          QuerySnapshot<Map<String, dynamic>> user =  await getUser(controller.text);
          for (var element in user.docs) {
            userData.add(element.data());
          }
          return List<ListTile>.generate(user.size, (int index) {
            final String item = userData.elementAt(index)["nickname"];
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  controller.closeView(item);
                });
              },
            );
          });
    });
  }

}
