import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/model/transaction_list_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:provider/provider.dart';

class AllTransactionList extends StatefulWidget {
  const AllTransactionList({Key? key}) : super(key: key);

  @override
  _AllTransactionListState createState() => _AllTransactionListState();
}

class _AllTransactionListState extends State<AllTransactionList> with AutomaticKeepAliveClientMixin<AllTransactionList> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  final ScrollController _scrollController = ScrollController();
  List<Transaction> transactions = [];
  bool isLoading = false;
  int pageCount = 0;
  int resultPerPage = 10;
  int totalCount = 0;
  TabController? controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getTransaction();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (totalCount != transactions.length) {
            getTransaction();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.onBackground,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
        child: transactions.isNotEmpty
            ? Stack(
                children: [
                  ListView.separated(
                    // key: UniqueKey(),
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: transactions.length,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime tempDate = DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(transactions[index].createdAt.toString());
                      String formattedDate = DateFormat('dd MMMM yyyy, E').format(tempDate);
                      String time = DateFormat.jm().format(DateTime.parse(transactions[index].createdAt.toString()));

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "$formattedDate $time",
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  '\$ ${transactions[index].totalAmt}',
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 15, color: ColorsUtils.greyAmount, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                              child: Text(
                                transactions[index].isCoachBooking == true
                                    ? 'Coach - ${transactions[index].setupName}'
                                    : 'Facility - ${transactions[index].setupName}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                              child: Text(
                                'Booking No. ${transactions[index].bookingNo!}',
                                maxLines: 3,
                                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 3, 16, 0),
                              child: Text(
                                transactions[index].paymentStatus == null || transactions[index].paymentStatus == "P"
                                    ? "Pending"
                                    : transactions[index].paymentStatus == "A"
                                        ? 'Success'
                                        : 'Failed',
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: transactions[index].paymentStatus == null || transactions[index].paymentStatus == "P"
                                        ? ColorsUtils.pendingAmount
                                        : transactions[index].paymentStatus == "A"
                                            ? ColorsUtils.greenAmount
                                            : ColorsUtils.redAmount,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  ),
                  isLoading
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                          ),
                        )
                      : const SizedBox(
                          width: 0,
                          height: 0,
                        ),
                ],
              )
            : isLoading
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    ),
                  )
                : const Center(
                    child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('No Transaction Found!'),
                  )),
      ),
    );
  }

  Future<void> getTransaction() async {
    setState(() {
      isLoading = true;
    });

    try {
      String requestStr = '';
      requestStr = 'PageStart=$pageCount&ResultPerPage=$resultPerPage&EndUserId=${OQDOApplication.instance.endUserID}';
      await Provider.of<ProfileViewModel>(context, listen: false).getTransactionList(requestStr).then(
        (value) async {
          Response res = value;
          if (res.statusCode == 500 || res.statusCode == 404) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            if (!mounted) return;
            TransactionListResponse notificationResponse = TransactionListResponse.fromJson(jsonDecode(res.body));
            if (notificationResponse.data != null && notificationResponse.data!.isNotEmpty) {
              setState(() {
                isLoading = false;
                List<Transaction> tempList = [];
                for (int i = 0; i < notificationResponse.data!.length; i++) {
                  if (notificationResponse.data![i].paymentStatus == 'A' || notificationResponse.data![i].paymentStatus == 'P') {
                    tempList.add(notificationResponse.data![i]);
                  }
                }
                transactions.addAll(tempList);
                totalCount = notificationResponse.totalCount!;
                pageCount = pageCount + 1;
              });
            } else {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
