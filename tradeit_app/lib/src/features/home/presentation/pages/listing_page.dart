import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tradeit_app/shared/widgets/custom_bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeit_app/src/features/auth/domain/entities/app_user.dart';
import 'package:tradeit_app/src/features/product_detail/presentation/pages/product_detail.dart';
import 'package:tradeit_app/shared/globalUser.dart';


final FirebaseFirestore firestore = FirebaseFirestore.instance;

class ListingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TradeIt'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4.0, // sombra inferior
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // ação futura de busca
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('ads').snapshots(), 
        builder: (context, snapshot){
          if(snapshot.hasError) return Center(child: Text("Erro ${snapshot.error}"));

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Nenhum dado disponível."));
          }
          final firebaseData = snapshot.data!.docs;

          return ListView.builder(itemCount: firebaseData.length, itemBuilder: (context, index){
            var ad = firebaseData[index];
            final data = ad.data() as Map<String, dynamic>?;
            // final userName = getUser(data?['ownerId']) as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1)
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                subtitle: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  
                      Text(data?['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                      SizedBox(height: 4),
                      
                      Text(data?['description']),
                      SizedBox(height: 4),

                      Text("Categoria: " + data?['category'], style: TextStyle(color: Colors.grey[700]))
                    
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/details', arguments: {'adId': ad.id, 'ownerId':  data?['ownerId']});
                },
              ),
            );
          });
        }
        
      ), 
      bottomNavigationBar: CustomBottomAppBar(currentIndex: 0),

    );
  }
}
