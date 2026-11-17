import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import '../config/app_config.dart';

class BlockchainService {
  late final Web3Client _client;
  late final DeployedContract _contract;

  Future<void> init() async {
    _client = Web3Client(AppConfig.rpcUrl, Client());
    final abi = await rootBundle.loadString('assets/abi/PinjaminDong.json');
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, 'PinjaminDong'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
  }

  Future<List> _baca(String fn, [List params = const []]) => _client.call(
        contract: _contract,
        function: _contract.function(fn),
        params: params,
      );

  Future<int> jumlahJenisAlat() async {
    final r = await _baca('jumlahJenisAlat');
    return (r.first as BigInt).toInt();
  }
}