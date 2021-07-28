import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:shopoholic/widgets/cart_item.dart';
import '../providers/cart.dart';
import './cart.dart';
import 'package:http/http.dart' as http;


class orderItem{
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  orderItem({
    @required this.id, 
    @required this.amount, 
    @required this.products, 
    @required this.dateTime});
}

class Orders with ChangeNotifier{
  List<orderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId, this._orders);

  List<orderItem> get orders{
    return[..._orders];
  }

  Future<void> fetchAndSetOrders() async{
    final url = Uri.parse(
      'https://flutter-app-d3e94-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
      final response = await http.get(url);
      final List<orderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
          return;
        }
      extractedData.forEach((orderId, orderData) { 
        loadedOrders.add(orderItem(
          id: orderId, 
          amount: orderData['amount'],  
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>).map((item) =>
          CartItem(
            id: item['id'], 
            price: item['price'], 
            quantity: item['quantity'], 
            title:item['title'] 
            )
            ).toList(),
          )
          );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();


  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      'https://flutter-app-d3e94-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
      final timeStamp = DateTime.now();
      final response = await http.post(url, body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': 
          cartProducts.map((cp) => {
            'id': cp.id,
            'title': cp.title,
            'quantity': cp.quantity,
            'price': cp.price,

          }).toList(),
        

      }));
      _orders.insert(0, orderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts
        ));
        notifyListeners();
  }

}