import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ostokenswap/Variables_For_Change/Changeable_Variables.dart';
import 'package:ostokenswap/provider/user.dart';
import 'package:ostokenswap/screens/swap_screen.dart';
import 'package:provider/provider.dart' as proveedor;


class MetaMaskProvider extends ChangeNotifier {

  // Connect Wallet
  static const operatingChain = 97;

  String currentAddress = '';

  int currentChain = -1;

  bool get isEnabled => ethereum != null;

  bool get isInOperatingChain => currentChain == operatingChain;

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;

  static final signer = provider!.getSigner();

  Future<void> connect(context) async {
    var userProvider = proveedor.Provider.of<UserProvider>(context, listen: false);

    if (isEnabled) {
      final accs = await ethereum!.requestAccount();
      if (accs.isNotEmpty) userProvider.currentAddress = accs.first;
      // Future.delayed(Duration(seconds: 5), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SwapScreen()));
      // });

      currentChain = await ethereum!.getChainId();
      notifyListeners();
    }
  }

  clear() {
    currentAddress = '';
    currentChain = -1;
    notifyListeners();
  }
  init() {
    if (isEnabled) {
      ethereum!.onAccountsChanged((accounts) {
        clear();
      });
      ethereum!.onChainChanged((accounts) {
        clear();
      });
    }
  }
}

class MetamaskWidgetProvider extends StatefulWidget {
  const MetamaskWidgetProvider({Key? key}) : super(key: key);

  @override
  State<MetamaskWidgetProvider> createState() => _MetamaskWidgetProviderState();
}

class _MetamaskWidgetProviderState extends State<MetamaskWidgetProvider> {
  @override
  Widget build(BuildContext context) {
    return proveedor.ChangeNotifierProvider(
      create: (context)=>MetaMaskProvider(),child: Column(children: [
        proveedor.Consumer<MetaMaskProvider>(
          builder: (context, provider, child) {
            late final String text;

            if (provider.isConnected && provider.isInOperatingChain) {
              text = 'Connected';

            } else if (provider.isConnected &&
                !provider.isInOperatingChain) {
              text =
              'Wrong chain. Please connect to ${MetaMaskProvider.operatingChain}';
            } else if (provider.isEnabled) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  CupertinoButton(
                    onPressed: () =>
                        context.read<MetaMaskProvider>().connect(context),
                    color: Colors.white,
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          'https://i0.wp.com/kindalame.com/wp-content/uploads/2021/05/metamask-fox-wordmark-horizontal.png?fit=1549%2C480&ssl=1',
                          width: 300,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              text = 'Please use a Web3 supported browser.';
            }

            return ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.purple, Colors.blue, Colors.red],
              ).createShader(bounds),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
      ),
    );
  }
}

class MetamaskSwap extends StatefulWidget {
  const MetamaskSwap({Key? key}) : super(key: key);

  @override
  State<MetamaskSwap> createState() => _MetamaskSwapState();
}
bool _absorbing=false;

class _MetamaskSwapState extends State<MetamaskSwap> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var userProvider = proveedor.Provider.of<UserProvider>(context);
    TextEditingController swapController = TextEditingController();
    final abi = [ "function transfer(address to, uint amount)",];
    final blockchainConnection = Contract(
      ChangeableVariables.tokenAddress,
      Interface(abi),
      provider!.getSigner(),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: AbsorbPointer(
        absorbing: _absorbing,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
          Text("GET SP",style: TextStyle(color: Colors.white,fontSize: 19),textAlign: TextAlign.center,),
          Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
            Container(margin: const EdgeInsets.only(right: 20),width: 250,
              child: TextFormField(keyboardType: TextInputType.number,controller: swapController,decoration: new InputDecoration(
                filled: true,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "USDC",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.blueGrey,
              ),),
            ),
            SizedBox(width: 10,),
            IconButton(onPressed: (){
            }, icon: Icon(Icons.swap_horiz,color: Colors.white,)),
            SizedBox(width: 10,),
            Container(margin: const EdgeInsets.only(left:20.0),width: 250,
              child: TextFormField(controller: swapController,decoration: new InputDecoration(
                filled: true,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                enabled: false,
                hintText: "SP",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.blueGrey,
              ),),
            ),
          ],),
          Container(
            child:ElevatedButton(onPressed: ()  async {
              if(double.parse(swapController.text) >= 1){
                setState(() {
                  _absorbing=true;
                });
                EasyLoading.show(status:'LOADING');
                final answer = pow(10, 18);
                final result = int.parse(swapController.text)*answer;
                final tx = await blockchainConnection.send('transfer', [ChangeableVariables.contractAddress, BigInt.from(result)]);
                final receipt = await tx.wait();
                if (receipt.status) {
                  await FirebaseFirestore.instance.collection('Users').doc(userProvider.currentAddress).update({"SP": FieldValue.increment(double.parse(swapController.text))});
                  EasyLoading.showSuccess('You have successfully bought ${swapController.text} SP');
                  setState(() {
                    userProvider.SP=userProvider.SP!+int.parse(swapController.text);
                    _absorbing=false;
                  });
                  // do something if transaction is success
                } else {
                  EasyLoading.showError('ERROR');
                  setState(() {
                    _absorbing=false;
                  });
                  // do something if transaction is failed
                }
              }
              else{
                EasyLoading.showError('ERROR');
                setState(() {
                  _absorbing=false;
                });
                Fluttertoast.showToast(msg: "Minimum deposit: 1 USDC");
              }
            }, child: Text("SWAP")),
          ),
        ],),
      ),
    );
  }
}

class MetamaskWithdraw extends StatefulWidget {
  const MetamaskWithdraw({Key? key}) : super(key: key);

  @override
  _MetamaskWithdrawState createState() => _MetamaskWithdrawState();
}

class _MetamaskWithdrawState extends State<MetamaskWithdraw> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });

  }
  @override
  Widget build(BuildContext context) {


    TextEditingController swapController = TextEditingController();

    final jsonInterface = Interface(ChangeableVariables.jsonAbi);
    final blockchainConnection = Contract(
      ChangeableVariables.contractAddress,
      jsonInterface,
      provider!.getSigner(),
    );
    var userProvider = proveedor.Provider.of<UserProvider>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: AbsorbPointer(
          absorbing: _absorbing,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
            Text("GET USDC",style: TextStyle(color: Colors.white,fontSize: 19),textAlign: TextAlign.center,),
            Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
              Container(margin: const EdgeInsets.only(right: 20),width: 250,
                child: TextFormField(keyboardType: TextInputType.number,controller: swapController,decoration: new InputDecoration(
                  filled: true,
                  contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "SP",
                  hintStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.blueGrey,
                ),),
              ),
              SizedBox(width: 10,),
              IconButton(onPressed: (){
              }, icon: Icon(Icons.swap_horiz,color: Colors.white,)),
              SizedBox(width: 10,),
              Container(margin: const EdgeInsets.only(left:20.0),width: 250,
                child: TextFormField(controller: swapController,decoration: new InputDecoration(
                  filled: true,
                  enabled: false,
                  contentPadding:
                  EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "USDC",
                  hintStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.blueGrey,
                ),),
              ),
            ],),
            Container(
              child:         ElevatedButton(onPressed: ()  async {
                setState(() {
                  _absorbing=true;
                });
                EasyLoading.show(status:'LOADING');

                if(double.parse(swapController.text) >= 1 && userProvider.SP!>= double.parse(swapController.text)){
                  final answer = pow(10, 18);
                  final result = double.parse(swapController.text)*answer;
                  final tx = await blockchainConnection.send('WithdrawToken',
                      [
                        ChangeableVariables.tokenAddress,
                        userProvider.currentAddress,
                        BigInt.from(result),
                      ]);
                  final receipt = await tx.wait();
                  if (receipt.status) {
                    await FirebaseFirestore.instance.collection('Users').doc(userProvider.currentAddress).update({"SP": FieldValue.increment(-double.parse(swapController.text))});
                    EasyLoading.showSuccess('You have successfully sell ${swapController.text} SP');
                    setState(() {
                      userProvider.SP=userProvider.SP!-int.parse(swapController.text);
                      _absorbing=false;
                    });
                  } else {
                    EasyLoading.showError('ERROR');
                    setState(() {
                      _absorbing=false;
                    });
                    // do something if transaction is failed
                  }
                }
                else{
                  Fluttertoast.showToast(msg: "Minimum withdraw: 1 USDC");
                }
              }, child: Text("SWAP")),
            ),
          ], ),
        ));
  }
}