import 'dart:math';
import 'package:web3dart/web3dart.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BlockchainWalletService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _pkKey = 'user_private_key';

  /// Initializes the wallet. Generates a new SECP256K1 private key if one doesn't exist.
  Future<EthPrivateKey> initWallet() async {
    String? pkHex = await _secureStorage.read(key: _pkKey);

    if (pkHex == null) {
      // 1. Generate mathematically secure entropy
      final credentials = EthPrivateKey.createRandom(Random.secure());
      // 2. Extract strictly private key hex
      pkHex = bytesToHex(credentials.privateKey, include0x: true);
      // 3. Store firmly in device Secure Enclave / Keystore
      await _secureStorage.write(key: _pkKey, value: pkHex);
      return credentials;
    }

    return EthPrivateKey.fromHex(pkHex);
  }

  /// Returns the EIP-55 standardized 0x public address corresponding to the device key
  Future<String> getPublicAddress() async {
    final credentials = await initWallet();
    return credentials.address.eip55With0x;
  }
}
