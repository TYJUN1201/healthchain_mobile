import 'dart:async';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/chain_metadata.dart';
import 'package:desnet/utils/constants.dart';
import 'package:desnet/utils/crypto/chain_data.dart';
import 'package:desnet/utils/string_constants.dart';
import 'package:desnet/widgets/chain_button.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({
    super.key,
    required this.web3App,
  });

  final Web3App web3App;

  @override
  ConnectPageState createState() => ConnectPageState();
}

class ConnectPageState extends State<ConnectPage> {
  bool _testnetOnly = false;
  final List<ChainMetadata> _selectedChains = [];
  bool _shouldDismissQrCode = true;

  @override
  Widget build(BuildContext context) {
    // Build the list of chain buttons, clear if the textnet changed
    final List<ChainMetadata> chains = ChainData.testChains;

    List<Widget> children = [];

    for (final ChainMetadata chain in chains) {
      // Build the button
      children.add(
        ChainButton(
          chain: chain,
          onPressed: () {
            setState(() {
              if (_selectedChains.contains(chain)) {
                _selectedChains.remove(chain);
              } else {
                _selectedChains.add(chain);
              }
            });
          },
          selected: _selectedChains.contains(chain),
        ),
      );
    }

    children.add(const SizedBox.square(dimension: 12.0));

    // Add a connect button
    children.add(
      ElevatedButton(
        onPressed: _selectedChains.isEmpty
            ? null
            : () =>
            _onConnect(showToast: (m) async {
              await showPlatformToast(child: Text(m), context: context);
            }),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
              if (states.contains(MaterialState.disabled)) {
                return StyleConstants.grayColor;
              }
              return StyleConstants.primaryColor;
            },
          ),
          minimumSize: MaterialStateProperty.all<Size>(const Size(
            1000.0,
            StyleConstants.linear48,
          )),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                StyleConstants.linear8,
              ),
            ),
          ),
        ),
        child: const Text(
          StringConstants.connect,
          style: StyleConstants.buttonText,
        ),
      ),
    );

    return Center(
      child: Container(
        padding: const EdgeInsets.all(
          StyleConstants.linear8,
        ),
        constraints: const BoxConstraints(
          maxWidth: StyleConstants.maxWidth,
        ),
        child: ListView(
          children: <Widget>[
            const Text(
              StringConstants.appTitle,
              style: StyleConstants.titleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: StyleConstants.linear16,
            ),
            const Text(
              StringConstants.selectChains,
              style: StyleConstants.subtitleText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: StyleConstants.linear16,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onConnect({Function(String message)? showToast}) async {
    debugPrint('Creating connection and session');
    // It is currently safer to send chains approvals on optionalNamespaces
    // but depending on Wallet implementation you may need to send some (for innstance eip155:1) as required
    final ConnectResponse res = await widget.web3App.connect(
      optionalNamespaces: {
        'eip155': RequiredNamespace(
          chains: _selectedChains.map((c) => c.chainId).toList(),
          methods: MethodsConstants.allMethods,
          events: EventsConstants.allEvents,
        ),
      },
    );

    final encodedUri = Uri.encodeComponent(res.uri.toString());
    final uri = 'metamask://wc?uri=$encodedUri';
    launchUrlString(uri, mode: LaunchMode.externalApplication);

    // } else {
    //   _showQrCode(res);
    // }

    try {
      debugPrint('Awaiting session proposal settlement');
      final _ = await res.session.future;

      showToast?.call(StringConstants.connectionEstablished);

      // Send off an auth request now that the pairing/session is established
      debugPrint('Requesting authentication');
      final AuthRequestResponse authRes = await widget.web3App.requestAuth(
        pairingTopic: res.pairingTopic,
        params: AuthRequestParams(
          chainId: _selectedChains[0].chainId,
          domain: Constants.domain,
          aud: Constants.aud,
          statement: 'Welcome to example flutter app',
        ),
      );

      debugPrint('Awaiting authentication response');
      final authResponse = await authRes.completer.future;

      if (authResponse.error != null) {
        debugPrint('Authentication failed: ${authResponse.error}');
        showToast?.call(StringConstants.authFailed);
      } else {
        showToast?.call(StringConstants.authSucceeded);
      }
    } catch (e) {
      debugPrint(e.toString());
      showToast?.call(StringConstants.connectionFailed);
    }
  }
}