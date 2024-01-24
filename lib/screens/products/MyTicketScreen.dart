import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '/Data/ProductData.dart';
import '/OdooApiCall_DataMapping/ResPartner.dart';
import '/OdooApiCall_DataMapping/SupportTicketandResPartner.dart';
import '/OdooApiCall_DataMapping/ToCheckIn_ToCheckOut_SupportTicket.dart';
import '/colors/Colors.dart';
import '/constant/Constants.dart';
import '/model/Product.dart';
import '/model/ProductInCart.dart';
import '/screens/launch/HomeScreen.dart';
import '/screens/products/MyAttendanceScreen.dart';
import '/screens/products/TicketDetailScreen.dart';
import '/util/RemoveGlowEffect.dart';
import '/util/size_config.dart';
import '/widgets/Styles.dart';
import '/util/Util.dart';
import '../../OdooApiCall/AllTicketsApi.dart';
import '../../OdooApiCall_DataMapping/SupportTicket.dart';
import '../LoadingAnimation.dart';
import '../authentication/LoginScreen.dart';



class MyTicketScreen extends StatefulWidget {
  @override
  _MyTicketScreenState createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  final scrollcontroller = ScrollController();
  late List<ResPartner> partnerlist ;
  var _buttonValue;

  @override
  void initState(){
    super.initState();
    print ('find out whether sessionId exist!?' + globalClient.sessionId!.id.toString());
    print ('find out is in globalsession '+ globalSession.toString());
   
  }

  @override
  void dispose() {
    scrollcontroller.dispose();  
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: isDarkMode(context)
          ? darkBackgroundColor
          : Theme.of(context).backgroundColor,
      /*appBar: buildAppBar(
        context,
        myTicketLabel,
        onBackPress: () {
          final CurvedNavigationBarState navState = getNavState();
          navState.setPage(0);
        },
      ),
      */
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: RemoveScrollingGlowEffect(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: getProportionateScreenWidth(10.0),
                ),
                FutureBuilder(
                  future: AllTicketsApi.getAllSupportTickets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AnimatedContainers(context);
                    } else if (snapshot.hasData) {
                      final tickets = snapshot.data as List<ToCheckInOutSupportTicket>;
                      if (tickets.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SvgPicture.asset(
                                isDarkMode(context)
                                    ? '$darkIconPath/empty_wishlist.svg'
                                    : '$lightIconPath/empty_wishlist.svg',
                                height: SizeConfig.screenHeight * 0.5,
                                width: double.infinity,
                              ),
                            ),
                            Text(
                              'No tickets found!',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ],
                        );
                      } else {
                        return buildSupportTickets(tickets);
                      }
                    } else if (snapshot.hasError) {
                      print('Error: ' + snapshot.error.toString());
                    print('Stack Trace: ' + snapshot.stackTrace.toString());
                    print('Data: ' + snapshot.data.toString());
                    print('Connection State: ' + snapshot.connectionState.toString());
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/json/lottieJson/no-internet.json',
                            repeat: true,
                          ),
                          const SizedBox(height:(10)),
                          Text('Unable to fetch data, please refresh and try again.', style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              fontWeight: Theme.of(context).textTheme.subtitle2?.fontWeight),textAlign: TextAlign.center,),
                          Text("${snapshot.error}"),
                        ],
                      );
                    } else {
                      return Text('Connection is broken,Some error ocurred! ${snapshot.connectionState}');
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),

      
    );
  }

  Widget buildSupportTickets(//List<dynamic>respartners,
  List<ToCheckInOutSupportTicket> supporttickets) =>

    ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: supporttickets.length,
      controller: scrollcontroller,
      itemBuilder: (context, index){
  if (index < supporttickets.length) {
        var supportticket = supporttickets[index];
        //var respartner = respartners[index];
        String unique = 'empty' ;
        
        var avatarUrl;
        if(supportticket.partner_id != null)
          avatarUrl= '${globalClient.baseURL}/web/image?model=res.partner&id=${supportticket.partner_id}&field=image_medium'; //&unique=$unique';
        else
          avatarUrl = null;
          DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
          DateTime input = inputFormat.parse (supportticket.created_date);
          DateTime MYtimezone = input.add(Duration(hours:8));                    
          String create_date = DateFormat("dd/MM/yyyy hh:mm:ss a").format(MYtimezone); //use this variable, because malaysia timezone is +8 hours from UTC. database gives u UTC time
          String respartner_id = supportticket.partner_id != null ? supportticket.partner_id : ''; //we need this to pass non null partner_id data to the attendance screen, to get the partner_latitude and longitude
          //field respartner_id is very important.
        return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(16),
          vertical: getProportionateScreenWidth(4),
        ),
        child: Card(
          elevation: 6,
          color: isDarkMode(context) ? darkGreyColor : Colors.white,
          shadowColor: Colors.grey.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          //create Inkwell to head the items
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          avatarUrl != null ?
                          (globalClient.sessionId?.id != null ?
                          CircleAvatar(
                              backgroundImage: NetworkImage(avatarUrl, headers: {"X-Openerp-Session-Id": globalClient.sessionId!.id}),
                              onBackgroundImageError: null,
                              backgroundColor: Color.fromARGB(255, 150, 190, 223),
                              radius:getProportionateScreenWidth(35)
                          )
                              : // Handle the case where sessionId is null
                          CircleAvatar(
                              backgroundImage: NetworkImage(avatarUrl),
                              onBackgroundImageError: null,
                              backgroundColor: Color.fromARGB(255, 150, 190, 223),
                              radius:getProportionateScreenWidth(35)
                          )
                          )
                              :
                          CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 150, 190, 223),
                              radius:getProportionateScreenWidth(35)
                          ),
                          SizedBox(width: getProportionateScreenWidth(10)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  
                                  Container(
                                    width: SizeConfig.screenWidth / 1.8,
                                    child: Text(
                                      '#${supportticket.ticket_number} ${supportticket.subject}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                            fontWeight: Theme.of(context).textTheme.subtitle2?.fontWeight),
                                      
                                    ),
                                  
                                  ),
                                  SizedBox(height: getProportionateScreenHeight(5)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: SizeConfig.screenWidth / 1.8,
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Icon(Icons.person,size: 20),
                                              ),
                                              TextSpan(
                                                text: ' '+supportticket.equipment_user,
                                                style: ticketScreensClickableLabelStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
      
                                    supportticket.partner_name != ''? 
                                      Container(
                                        width: SizeConfig.screenWidth / 1.8,
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Icon(Icons.business,size: 20),
                                              ),
                                              TextSpan(
                                                text: ' '+supportticket.partner_name.toString(),
                                                style:Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                  //decoration:
                                                  //    TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )                               
                                    :const SizedBox(),         
                                    Container(
                                      width: SizeConfig.screenWidth / 1.8,
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          text: TextSpan(
                                            children: [
                                              WidgetSpan(
                                                child: Icon(Icons.date_range,size: 20),
                                              ),
                                              TextSpan(
                                                text: ' '+create_date,
                                                style:Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                  //decoration:
                                                  //    TextDecoration.lineThrough,
                                                  color: Theme.of(context).textTheme.caption?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ),
          
                                    SizedBox(height : getProportionateScreenHeight(10)),
                                    Container(
                                      width: SizeConfig.screenWidth / 2,
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          text: TextSpan(
                                            children: [ 
                                              supportticket.category_name != '' && supportticket.subcategory_name == ''
                                              ?                            
                                              TextSpan(                 
                                                text: '• '+supportticket.category_name,
                                                style:Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                ?.copyWith(
                                                  decoration: TextDecoration.underline,
                                                  color: orangeredColor                                  
                                                ),
                                              ) :
          
                                              supportticket.category_name !='' && supportticket.subcategory_name != ''
                                              ?                                           
                                              TextSpan( 
                                                children: [            
                                                  TextSpan (                                            
                                                    text: '• '+supportticket.category_name,
                                                    style:Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                      decoration: TextDecoration.underline,
                                                      color: orangeredColor                                  
                                                    )
                                                  ),
                                                  TextSpan(                                              
                                                    text: ' '+'• '+supportticket.subcategory_name,
                                                    style:Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.copyWith(
                                                    ),
                                                  )
                                                ]
                                              ) 
                                              : 
                                              TextSpan(),                                 
                                            ],
                                          ),
                                        ),
                                    ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.delete,
                            size: 22,
                            color: primaryColor,
                          ),
                        ),
                        onTap: () {
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(4),
                      ),
                      child:      
                      ElevatedButton(     
                        onPressed:(){
                          print('onpress button pressed');
                          print('check in value is '+supportticket.check_in);
                          print('_buttonValue' + _buttonValue);
                          if (_buttonValue == 'CHECK IN' || _buttonValue == 'CHECK OUT')
                          {
                            print('check in button pressed');
                            Navigator.push(
                              context,
                              OpenUpwardsPageRoute(child: MyAttendanceScreen(
                                supportticket, respartner_id), 
                                direction: AxisDirection.up)).then((value){
                                  setState((){
                                    
                                  });
                            }); 
                          }
                          else if (_buttonValue == 'SUBMIT JOB DETAILS'){
                            Navigator.push(
                              context,
                              OpenUpwardsPageRoute(child: MyAttendanceScreen(
                                supportticket, respartner_id), 
                                direction: AxisDirection.up)).then((value){
                                  setState((){
                                    
                                  });
                            }); 

                          }
                          else if (_buttonValue == 'SUBMIT CMFORM'){
                            Navigator.push(
                              context,
                              OpenUpwardsPageRoute(child: MyAttendanceScreen(
                                supportticket, respartner_id), 
                                direction: AxisDirection.up)).then((value){
                                  setState((){

                                  });
                            }); 

                          }
                        } ,
                        autofocus: true,
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.resolveWith<double>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return 16;
                            return 0;
                          }),
                          //shape: RectangularRangeSliderTrackShap
                          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                          
                          ),
             
                        child: RichText(
                          text: TextSpan(
                            children: [                    
                              TextSpan(
                                text: supportticket.check_in == '' && supportticket.check_out == '' 
                                    ? _buttonValue = 'CHECK IN'
                                    : supportticket.check_in  != '' && supportticket.check_out == ''
                                    ? _buttonValue = 'CHECK OUT'
                                    : supportticket.check_in  != '' && supportticket.check_out != ''
                                    ? _buttonValue = 'SUBMIT FORM'
                                    : null,
                                    
                                    style: Theme.of(context).textTheme.button?.copyWith(
                                        fontFamily: poppinsFont,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,         
                                    ),
                              ),          
                            ],
                          ),
                        ),
                      )                      
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {                         
              Navigator.push(
                context,
                OpenUpwardsPageRoute(child: TicketDetailScreen(
                  supportticket, respartner_id), 
                  direction: AxisDirection.left)).then((value){
                  }); 
            }
          ),
          
        ),
      //),
      );
  } else {
    print('Index $index out of range!');
  }
      } 


    );
  

  void addProductToCart(Product product, bool isAddedInCart) {
    product.isAddedInCart = isAddedInCart;
    setState(
      () {
        if (isAddedInCart) {
          myCartData.add(
            ProductInCart(
              product,
              1,
            ),
          );
        } else {
          myCartData.removeWhere((element) => element.product == product);
        }
        HomeScreen.cartItemCount = myCartData.length;
      },
    );
  }
}
