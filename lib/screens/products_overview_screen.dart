import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '/widgets/badge.dart';
import '../providers/cart.dart';
import '../widgets/products_grid.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';

enum filterOptions{
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {

    //Provider.of<Products>(context).fetchAndSetProduct();
    
    super.initState();
  }
  @override
  void didChangeDependencies() {
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      
      Provider.of<Products>(context).fetchAndSetProduct().then((value) {
        setState(() {
          _isLoading = false;
        });
        
      });

    }
    _isInit = false;
    
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productsContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('ShopoHolic'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (filterOptions selectedValue){
              setState(() {
                if(selectedValue == filterOptions.Favorites){
                  _showOnlyFavorites = true;
              }else{
                  _showOnlyFavorites = false;
              }
                
              });
              
            },
            icon:Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites!'), value: filterOptions.Favorites),
              PopupMenuItem(
                child: Text('Show All'), value: filterOptions.All),
            ],
            ),
          Consumer<Cart>(builder: (_ , cart, ch ) => Badge(
            child: ch,
             value: cart.itemCount.toString() , 
              ),
              child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              } ,
              ),
           ) 
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading ? 
      Center(child: CircularProgressIndicator(),) :
       ProductsGrid(_showOnlyFavorites),
    );
  }
}
