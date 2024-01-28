import 'package:flutter/material.dart';
import 'package:desnet/models/chain_metadata.dart';
import 'package:desnet/utils/crypto/chain_data.dart';
import 'package:desnet/utils/crypto/eip155.dart';
import 'package:desnet/utils/crypto/solana_data.dart';

String getChainName(String chain) {
  try {
    return ChainData.allChains
        .where((element) => element.chainId == chain)
        .first
        .name;
  } catch (e) {
    debugPrint('Invalid chain');
  }
  return 'Unknown';
}

ChainMetadata getChainMetadataFromChain(String chain) {
  try {
    return ChainData.allChains
        .where((element) => element.chainId == chain)
        .first;
  } catch (e) {
    debugPrint('Invalid chain');
  }
  return ChainData.testChains[0];
}

List<String> getChainMethods(ChainType value) {
  return EIP155.methods.values.toList();
}

List<String> getChainEvents(ChainType value) {
  return EIP155.events.values.toList();
}
