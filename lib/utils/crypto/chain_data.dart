import 'package:flutter/material.dart';
import 'package:desnet/models/chain_metadata.dart';

class ChainData {
  static final List<ChainMetadata> testChains = [
    ChainMetadata(
      type: ChainType.eip155,
      chainId: 'eip155:5',
      name: 'Ethereum Sepolia',
      logo: '/chain-logos/eip155-1.png',
      color: Colors.blue.shade300,
      isTestnet: true,
      rpc: ['https://sepolia.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161'],
    ),
    ChainMetadata(
        type: ChainType.eip155,
        chainId: 'eip155:1337',
        name: 'Ethereum Ganache',
        logo: '/chain-logos/eip155-137.png',
        color: Colors.purple.shade300,
        isTestnet: true,
        rpc: ['http://10.0.2.2:8545/'],
    ),
  ];

  static final List<ChainMetadata> allChains = [...testChains];
}
