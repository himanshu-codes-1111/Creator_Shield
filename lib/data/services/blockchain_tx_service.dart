import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/foundation.dart';

import 'blockchain_wallet_service.dart';

class BlockchainTxService {
  // Public Polygon Amoy Testnet RPC
  final String _rpcUrl = 'https://rpc-amoy.polygon.technology';
  late Web3Client _client;
  final BlockchainWalletService _walletService;

  BlockchainTxService(this._walletService) {
    _client = Web3Client(_rpcUrl, http.Client());
  }

  /// Formulates an EVM transaction and directly embeds the fileHash into the transaction `data` payload
  Future<String> anchorProofTransaction(String fileHashSha256) async {
    final credentials = await _walletService.initWallet();

    // Convert ASCII string or HEX string to Uint8List for custom Calldata
    Uint8List payload;
    try {
      // If it's already a clean hex string
      payload = hexToBytes(fileHashSha256);
    } catch (_) {
      // Fallback ascii encoding
      payload = Uint8List.fromList(utf8.encode(fileHashSha256));
    }

    // We send a 0 MATIC transaction to our own wallet address.
    // The proof of existence is officially anchored because the block explorer permanently stores the TX "data" payload.
    final tx = Transaction(
      to: credentials.address,
      value: EtherAmount.zero(),
      data: payload,
    );

    try {
      final txId = await _client.sendTransaction(
        credentials,
        tx,
        chainId: 80002,
      );
      return txId;
    } catch (e) {
      if (e.toString().contains('funds') || e.toString().contains('gas')) {
        debugPrint('\n================================');
        debugPrint('INSUFFICIENT FUNDS ERROR!');
        debugPrint('Your device-generated Polygon Amoy Wallet Address is:');
        debugPrint(credentials.address.eip55With0x);
        debugPrint('Go to https://faucet.polygon.technology/ and request MATIC for this address!');
        debugPrint('================================\n');
      }
      rethrow;
    }
  }

  /// Fetches the latest block number purely to populate our UI dashboard
  Future<int> getBlockNumber() async {
    return await _client.getBlockNumber();
  }
}
