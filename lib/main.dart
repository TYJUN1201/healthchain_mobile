import 'package:desnet/pages/metamask_encrypt_decrypt.dart';
import 'package:flutter/material.dart';
import 'package:desnet/pages/profile_page.dart';
import 'package:desnet/services/IPFS/upload_file.dart';
import 'package:desnet/services/cryptography/aes_algorithm.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/chain_metadata.dart';
import 'package:desnet/models/page_data.dart';
import 'package:desnet/pages/auth_page.dart';
import 'package:desnet/pages/connect_page.dart';
import 'package:desnet/pages/pairings_page.dart';
import 'package:desnet/pages/sessions_page.dart';
import 'package:desnet/utils/constants.dart';
import 'package:desnet/utils/crypto/chain_data.dart';
import 'package:desnet/utils/crypto/helpers.dart';
import 'package:desnet/utils/dart_defines.dart';
import 'package:desnet/utils/string_constants.dart';
import 'package:desnet/widgets/event_widget.dart';



// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   final String pinataApiKey =
//       'ff3f5300b2cd6aac0e81'; // Replace with your actual API key
//   final String pinataSecretApiKey =
//       '5fc2f07e17c822cb7b287b57f41e9f32a7f5bc746a78f0064682791c4751165e'; //'5St1vYV4xfYX_dTs1K4VbuRspePITHSiz5jy7EK-Qu88aIFQ9zf2LTSbyinPDXKV';
//   // '5fc2f07e17c822cb7b287b57f41e9f32a7f5bc746a78f0064682791c4751165e'; // Replace with your actual secret API key
//
//   final String emr = "{'name':'pikachu'}";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pin File to IPFS'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 final AESEncryption aesEncryption = AESEncryption();
//                 final SecretBox secretBox;
//                 encrypted = await aesEncryption.encryptAES(emr);
//
//                 pinFileToIPFS(pinataApiKey, pinataSecretApiKey,
//                     utf8.decode(encrypted.cipherText), 'encrypted_AESKey');
//               },
//               child: Text('Pin File to IPFS'),
//             ),
//             SizedBox(
//               width: 300.0, // Set the desired width
//               height: 200.0,
//               child:
//                   PatientProfilePage(), // Assuming PatientProfilePage is a widget
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MainApp());
// }
//
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     const String appTitle = "HealthChain";
//     return MaterialApp(
//       title: appTitle,
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(appTitle),
//       ),
//       body: const Center(
//         child: PatientProfilePage(),
//       ),
//     ), //MyHomePage(),
//     );
//   }
// }


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StringConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _initializing = true;

  Web3App? _web3App;

  List<PageData> _pageDatas = [];
  int _selectedIndex = 0;

  // SessionData? _selectedSession;
  // List<SessionData> _allSessions = [];
  // List<PairingInfo> _allPairings = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    // try {
    debugPrint('Project ID: ${DartDefines.projectId}');
    _web3App = await Web3App.createInstance(
      projectId: DartDefines.projectId,
      logLevel: LogLevel.info,
      metadata: const PairingMetadata(
        name: 'Example dApp',
        description: 'Example dApp',
        url: 'https://walletconnect.com/',
        icons: [
          'https://images.prismic.io/wallet-connect/65785a56531ac2845a260732_WalletConnect-App-Logo-1024X1024.png'
        ],
        redirect: Redirect(
          native: 'myflutterdapp://',
          universal: 'https://walletconnect.com',
        ),
      ),
    );

    // Loop through all the chain data
    for (final ChainMetadata chain in ChainData.allChains) {
      // Loop through the events for that chain
      for (final event in getChainEvents(chain.type)) {
        debugPrint('registerEventHandler $event for chain ${chain.chainId}');
        _web3App!.registerEventHandler(chainId: chain.chainId, event: event);
      }
    }

    // Register event handlers
    _web3App!.onSessionPing.subscribe(_onSessionPing);
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);
    _web3App!.onSessionUpdate.subscribe(_onSessionUpdate);
    _web3App!.core.relayClient.onRelayClientConnect.subscribe(_setState);
    _web3App!.core.relayClient.onRelayClientDisconnect.subscribe(_setState);
    _web3App!.onSessionConnect.subscribe(_onSessionConnect);

    setState(() {
      _pageDatas = [
        PageData(
          page: ConnectPage(web3App: _web3App!),
          title: StringConstants.connectPageTitle,
          icon: Icons.home,
        ),
        PageData(
          page: PairingsPage(web3App: _web3App!),
          title: StringConstants.pairingsPageTitle,
          icon: Icons.connect_without_contact_sharp,
        ),
        PageData(
          page: SessionsPage(web3App: _web3App!),
          title: StringConstants.sessionsPageTitle,
          icon: Icons.confirmation_number_outlined,
        ),
        PageData(
          page: AuthPage(web3App: _web3App!),
          title: StringConstants.authPageTitle,
          icon: Icons.lock,
        ),
        PageData(
          page: PatientProfilePage(web3App: _web3App!),
          title: 'Profile',
          icon: Icons.person,
        ),
      ];

      _initializing = false;
    });
    // } on WalletConnectError catch (e) {
    //   print(e.message);
    // }
  }

  void _setState(dynamic args) => setState(() {});

  @override
  void dispose() {
    _web3App!.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3App!.core.relayClient.onRelayClientConnect.unsubscribe(_setState);
    _web3App!.core.relayClient.onRelayClientDisconnect.unsubscribe(_setState);
    _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    _web3App!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: StyleConstants.primaryColor,
        ),
      );
    }

    final List<Widget> navRail = [];
    if (MediaQuery.of(context).size.width >= Constants.smallScreen) {
      navRail.add(_buildNavigationRail());
    }
    navRail.add(
      Expanded(
        child: Stack(
          children: [
            _pageDatas[_selectedIndex].page,
            Positioned(
              bottom: StyleConstants.magic20,
              right: StyleConstants.magic20,
              child: Row(
                children: [
                  Text(_web3App!.core.relayClient.isConnected
                      ? 'Relay Connected'
                      : 'Relay Disconnected'),
                  Switch(
                    value: _web3App!.core.relayClient.isConnected,
                    onChanged: (value) {
                      if (!value) {
                        _web3App!.core.relayClient.disconnect();
                      } else {
                        _web3App!.core.relayClient.connect();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageDatas[_selectedIndex].title),
      ),
      bottomNavigationBar:
      MediaQuery.of(context).size.width < Constants.smallScreen
          ? _buildBottomNavBar()
          : null,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: navRail,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.indigoAccent,
      // called when one tab is selected
      onTap: (int index) {
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

  void _onSessionPing(SessionPing? args) {
    debugPrint('[$runtimeType] _onSessionPing $args');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: StringConstants.receivedPing,
          content: 'Topic: ${args!.topic}',
        );
      },
    );
  }

  void _onSessionEvent(SessionEvent? args) {
    debugPrint('[$runtimeType] _onSessionEvent $args');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: StringConstants.receivedEvent,
          content:
          'Topic: ${args!.topic}\nEvent Name: ${args.name}\nEvent Data: ${args.data}',
        );
      },
    );
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint(jsonEncode(event?.session.toJson()));
  }

  void _onSessionUpdate(SessionUpdate? args) {
    debugPrint('[$runtimeType] _onSessionUpdate $args');
  }
}

