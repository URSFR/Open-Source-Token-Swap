import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ostokenswap/blockchain/metamask.dart';
import 'package:provider/provider.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/user.dart';


class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {

  @override
  void initState() {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    // TODO: implement initState

    Fluttertoast.showToast(msg: "ID "+userProvider.currentAddress!);

    if(userProvider.currentAddress!=null&&userProvider.currentAddress!=""){

      var document = FirebaseFirestore.instance.collection('Users').doc(userProvider.currentAddress!);
      document.get().then((document) async {
        if(document.exists){
          setState(() {
            userProvider.SP = document["SP"];
          });
        }
        else{
          FirebaseFirestore.instance.collection('Users').doc(userProvider.currentAddress!).set({
            "SP":0,
          }).whenComplete(() {
            setState(() {
              userProvider.SP = 0;

            });
          });
        }


      });
    }
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var userProvider = Provider.of<UserProvider>(context);
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Colors.blueGrey,
              bottom: TabBar(
                tabs: [
                  Tab(text: "Deposit"),
                  Tab(text: "Withdraw",),
                ],
              ),
            ),
          ),
          body:  TabBarView(
              children:
              [
                MetamaskSwap(),
                MetamaskWithdraw(),
              ]

          ),
          bottomSheet: SolidBottomSheet(
            headerBar: Container(
              color: Theme.of(context).primaryColor,
              height: 50,
              child: Center(
                child: GestureDetector(
                    onTap: (){
                      Fluttertoast.showToast(msg: userProvider.SP.toString());
                    },
                    child: Text("MY SP: "+userProvider.SP.toString())),
              ),
            ),
            body: Container(
              color: Colors.white,
              height: 30,
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    launch("https://github.com/URSFR");
                  },
                  child: Text(
                    "Made by URSFR",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

    );

  }
}