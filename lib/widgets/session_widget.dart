import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:desnet/models/chain_metadata.dart';
import 'package:desnet/utils/constants.dart';
import 'package:desnet/utils/crypto/eip155.dart';
import 'package:desnet/utils/crypto/helpers.dart';
import 'package:desnet/utils/string_constants.dart';
import 'package:desnet/widgets/method_dialog.dart';

class SessionWidget extends StatefulWidget {
  const SessionWidget({
    super.key,
    required this.session,
    required this.web3App,
  });

  final SessionData session;
  final Web3App web3App;

  @override
  SessionWidgetState createState() => SessionWidgetState();
}

class SessionWidgetState extends State<SessionWidget> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      Text(
        widget.session.peer.metadata.name,
        style: StyleConstants.titleText,
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: StyleConstants.linear16,
      ),
      Text(
        '${StringConstants.sessionTopic}${widget.session.topic}',
      ),
    ];

    // Get all of the accounts
    final List<String> namespaceAccounts = [];

    // Loop through the namespaces, and get the accounts
    for (final Namespace namespace in widget.session.namespaces.values) {
      namespaceAccounts.addAll(namespace.accounts);
    }

    // Loop through the namespace accounts and build the widgets
    for (final String namespaceAccount in namespaceAccounts) {
      children.add(
        _buildAccountWidget(
          namespaceAccount,
        ),
      );
    }

    // Add a delete button
    children.add(
      Container(
        width: double.infinity,
        height: StyleConstants.linear48,
        margin: const EdgeInsets.symmetric(
          vertical: StyleConstants.linear8,
        ),
        child: ElevatedButton(
          onPressed: () async {
            await widget.web3App.disconnectSession(
                topic: widget.session.topic,
                reason: Errors.getSdkError(
                  Errors.USER_DISCONNECTED,
                ));
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.red,
            ),
          ),
          child: const Text(
            StringConstants.delete,
            style: StyleConstants.buttonText,
          ),
        ),
      ),
    );

    return ListView(
      children: children,
    );
  }

  Widget _buildAccountWidget(String namespaceAccount) {
    final String chainId = NamespaceUtils.getChainFromAccount(
      namespaceAccount,
    );
    final String account = NamespaceUtils.getAccount(
      namespaceAccount,
    );
    final ChainMetadata chainMetadata = getChainMetadataFromChain(chainId);

    final List<Widget> children = [
      Text(
        chainMetadata.name,
        style: StyleConstants.subtitleText,
      ),
      const SizedBox(
        height: StyleConstants.linear8,
      ),
      Text(
        account,
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: StyleConstants.linear8,
      ),
      const Text(
        StringConstants.methods,
        style: StyleConstants.subtitleText,
      ),
    ];

    children.addAll(
      _buildChainMethodButtons(
        chainMetadata,
        account,
      ),
    );

    // final ChainMetadata
    return Container(
      width: double.infinity,
      // height: StyleConstants.linear48,
      padding: const EdgeInsets.all(
        StyleConstants.linear8,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: StyleConstants.linear8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: chainMetadata.color,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(
            StyleConstants.linear8,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  List<Widget> _buildChainMethodButtons(
    ChainMetadata chainMetadata,
    String address,
  ) {
    final List<Widget> buttons = [];
    // Add Methods
    for (final String method in getChainMethods(chainMetadata.type)) {
      buttons.add(
        Container(
          width: double.infinity,
          height: StyleConstants.linear48,
          margin: const EdgeInsets.symmetric(
            vertical: StyleConstants.linear8,
          ),
          child: ElevatedButton(
            onPressed: () async {
              final walletUrl = widget.session.peer.metadata.redirect?.native;
              if ((walletUrl ?? '').isNotEmpty) {
                launchUrlString(
                  walletUrl!,
                  mode: LaunchMode.externalApplication,
                );
              }
              Future<dynamic> future = callChainMethod(
                chainMetadata.type,
                method,
                chainMetadata,
                address,
              );
              MethodDialog.show(context, method, future);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                chainMetadata.color,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    StyleConstants.linear8,
                  ),
                ),
              ),
            ),
            child: Text(
              method,
              style: StyleConstants.buttonText,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Future<dynamic> callChainMethod(
    ChainType type,
    String method,
    ChainMetadata chainMetadata,
    String contractAddress,
  ) async {
    DeployedContract contract = DeployedContract(
        ContractAbi.fromJson(
            jsonEncode(jsonDecode(await rootBundle
                .loadString("assets/json/Storage.json"))["abi"]),
            'Storage'),
        EthereumAddress.fromHex(contractAddress));

    final ContractFunction contractFunction = contract.function('store');

    final Transaction tx = Transaction.callContract(
      contract: contract,
      function: contractFunction,
      parameters: ['QmX5TodM66Djvp7a9TPxUeUBzt2DfPU8hb2Q3UrYw6VeZY'],
    );

    switch (type) {
      case ChainType.eip155:
        return EIP155.callMethod(
            web3App: widget.web3App,
            topic: widget.session.topic,
            method: EIP155Methods.ethSendTransaction,
            chainId: 'eip155:1337',
            toAddress: '0xDB5332457aed22aB904212c2B8b40C18e6937440',
            fromAddress: '0xd2415d678954c68e5132B3b73C7f327EA7adbb20',
            parameters: ['QmX5TodM66Djvp7a9TPxUeUBzt2DfPU8hb2Q3UrYw6VeZY'],
            transaction: tx);

      default:
        return Future<dynamic>.value();
    }
  }
}
