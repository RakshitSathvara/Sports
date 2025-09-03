// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/cancellation_request_list_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/viewmodels/service_providers_cancellation_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/network_interceptor.dart';

class EnduserCancellationRequestPage extends StatefulWidget {
  const EnduserCancellationRequestPage({super.key});

  @override
  State<EnduserCancellationRequestPage> createState() => _EnduserCancellationRequestPageState();
}

class _EnduserCancellationRequestPageState extends State<EnduserCancellationRequestPage> with TickerProviderStateMixin {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  final ScrollController _scrollController = ScrollController();
  List<CancellationRequest> cancellationRequestList = [];
  bool isLoading = true;
  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  int? selectedRequestVerificationId;
  String acceptRejectString = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getTransaction(OQDOApplication.instance.endUserID!);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (totalCount != cancellationRequestList.length) {
            getTransaction(OQDOApplication.instance.endUserID!);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    if (cancellationRequestList.isNotEmpty) {
      for (var cancellationRequest in cancellationRequestList) {
        cancellationRequest.expireTimeController?.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cancellation Requests',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.onBackground,
          child: cancellationRequestList.isNotEmpty
              ? Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: cancellationRequestList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var cancellationRequest = cancellationRequestList[index];
                          return cancellationRequestListTile(cancellationRequest);
                        },
                      ),
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
                        child: Text('No cancellation request found!'),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget cancellationRequestListTile(CancellationRequest cancellationRequest) {
    String bookingDate = "";
    String createdDate = "";
    if (cancellationRequest.bookingDate != null && cancellationRequest.bookingDate != null) {
      DateTime tempDate = DateTime.parse(cancellationRequest.bookingDate.toString());
      bookingDate = DateFormat('dd MMMM - EEEE').format(tempDate);
    }
    if (cancellationRequest.createdAt != null && cancellationRequest.createdAt != null) {
      DateTime tempDate = DateTime.parse(convertUtcToSgt(cancellationRequest.createdAt.toString()));
      createdDate = DateFormat('dd-MM-yyyy, HH:mm').format(tempDate);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
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
                        bookingDate,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextView(
                          label: 'Refund Amount: ',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                        ),
                        CustomTextView(
                          label: 'S\$ ${cancellationRequest.status == 'R' ? 0.0 : (cancellationRequest.amount?.toStringAsFixed(2) ?? 0.0)}',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: OQDOThemeData.buttonColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextView(
                      label: cancellationRequest.startTime ?? "",
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                    ),
                    CustomTextView(
                      label: cancellationRequest.endTime != null && cancellationRequest.endTime!.isNotEmpty ? "-${cancellationRequest.endTime}" : "",
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CustomTextView(
                      label: 'S\$ ${cancellationRequest.ratePerHour ?? 0.0}/hour',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                CustomTextView(
                  label: 'Initiated on - $createdDate',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                ),
                const SizedBox(
                  height: 2,
                ),
                Visibility(
                  visible: cancellationRequest.status == 'P',
                  child: Row(children: [
                    CustomTextView(
                      label: 'Waiting time ',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                    ),
                    CustomTimer(
                        controller: cancellationRequest.expireTimeController!,
                        builder: (state, time) {
                          return CustomTextView(
                            label: "${time.hours}:${time.minutes}:${time.seconds}",
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                          );
                        })
                  ]),
                ),
                const SizedBox(
                  height: 2,
                ),
                CustomTextView(
                  label: 'Requested to: ${cancellationRequest.facilityName ?? ""}',
                  maxLine: 3,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextView(
                      label: 'Status : ',
                      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                    ),
                    CustomTextView(
                      label: cancellationRequest.status == 'A'
                          ? 'Accepted'
                          : cancellationRequest.status == 'R'
                              ? 'Rejected'
                              : 'Pending',
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: cancellationRequest.status == 'A'
                            ? ColorsUtils.greenAmount
                            : cancellationRequest.status == 'R'
                                ? ColorsUtils.redAmount
                                : ColorsUtils.yellowStatus,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getTransaction(String enduserId) async {
    setState(() {
      isLoading = true;
    });
    try {
      String requestStr = 'ResultPerPage=$resultPerPage&PageStart=$pageCount&SeachQuery=&EndUserId=$enduserId';
      CancellationRequestsListModel cancellationRequestListResponse =
          await Provider.of<ServiceProvidersCancellationViewModel>(context, listen: false).getEnduserCancellationRequests(requestStr);
      // if (!mounted) return;

      if (cancellationRequestListResponse.data != null && cancellationRequestListResponse.data!.isNotEmpty) {
        setState(() {
          isLoading = false;
          cancellationRequestList.addAll(cancellationRequestListResponse.data!);
          totalCount = cancellationRequestListResponse.totalCount!;
          pageCount = pageCount + 1;
        });
        if (cancellationRequestList.isNotEmpty) {
          for (var cancellationRequest in cancellationRequestList) {
            if (cancellationRequest.expiredAt != null && cancellationRequest.expiredAt != null) {
              debugPrint("expire time is :- ${cancellationRequest.expiredAt.toString()}");
              debugPrint("Converted expire time to IST is :- ${convertUtcToSgt(cancellationRequest.expiredAt.toString())}");
              var expireTime = DateTime.parse(convertUtcToSgt(cancellationRequest.expiredAt.toString()));
              debugPrint("Parsed expire time is :- ${expireTime.toString()}");
              var currentTime = DateTime.now();
              var duration = expireTime.difference(currentTime);
              if (duration.inMilliseconds != 0 && !(duration.inMilliseconds.isNegative)) {
                cancellationRequest.expireTime = Duration(
                  hours: duration.inHours,
                  minutes: duration.inMinutes.remainder(60),
                  seconds: duration.inSeconds.remainder(60),
                );
              }
            }
            cancellationRequest.expireTimeController = CustomTimerController(
              vsync: this,
              begin: cancellationRequest.expireTime ?? const Duration(hours: 0, minutes: 0, seconds: 0),
              end: const Duration(),
              initialState: CustomTimerState.reset,
              interval: CustomTimerInterval.milliseconds,
            );
            cancellationRequest.expireTimeController?.reset();
          }
          for (var cancellationRequest in cancellationRequestList) {
            if (cancellationRequest.status == "P") {
              cancellationRequest.expireTimeController?.start();
            }
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on CommonException catch (error) {
      showLog('common$error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
