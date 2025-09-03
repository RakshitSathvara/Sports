// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/model/cancellation_request_list_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/viewmodels/service_providers_cancellation_view_model.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class FacilityCancellationRequestPage extends StatefulWidget {
  const FacilityCancellationRequestPage({super.key});

  @override
  State<FacilityCancellationRequestPage> createState() => _FacilityCancellationRequestPageState();
}

class _FacilityCancellationRequestPageState extends State<FacilityCancellationRequestPage> with TickerProviderStateMixin {
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

  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getTransaction(OQDOApplication.instance.facilityID!, false);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (totalCount != cancellationRequestList.length) {
            pageCount = pageCount + 1;
            getTransaction(OQDOApplication.instance.facilityID!, false);
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
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.onBackground,
      child: cancellationRequestList.isNotEmpty
          ? Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: cancellationRequestList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var cancellationRequest = cancellationRequestList[index];
                          return cancellationRequestListTile(cancellationRequest);
                        },
                      ),
                    ),
                    bottomBtnView(),
                  ],
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
    );
  }

  String minutesToTime(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = remainingMinutes.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes';
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                      checkColor: Theme.of(context).colorScheme.primaryContainer,
                      value: selectedRequestVerificationId == cancellationRequest.bookingRefundVerificationId,
                      onChanged: (value) {
                        if (value ?? false) {
                          selectedRequestVerificationId = cancellationRequest.bookingRefundVerificationId;
                        } else {
                          selectedRequestVerificationId = null;
                        }
                        setState(() {});
                      }),
                ),
              ],
            ),
          ),
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
                          label: 'S\$ ${cancellationRequest.amount?.toStringAsFixed(2) ?? 0.0}',
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
                      label: "-${cancellationRequest.endTime ?? ""}",
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
                  label: 'Initiated - on $createdDate',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(children: [
                  CustomTextView(
                    label: 'Time left to reject ',
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
                const SizedBox(
                  height: 2,
                ),
                CustomTextView(
                  label: 'Requested by: ${cancellationRequest.firstName ?? ""} ${cancellationRequest.lastName ?? ""}',
                  maxLine: 3,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String convertDateToVisibleForm(String date) {
    String parsingDate = '';
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    String month = DateFormat.yMMMM().format(dateTime);
    parsingDate = '${date.split('-')[2]} ${month.split(' ')[0].toUpperCase()} \'${date.split('-')[0].substring(date.split('-')[0].length - 2)}';
    return parsingDate;
  }

  Widget bottomBtnView() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFCECECE)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Color(0xFFCECECE),
                    ),
                  ),
                ),
              ),
              onPressed: selectedRequestVerificationId != null
                  ? () {
                      updateFacilityBookingRefundStatus(verificationId: selectedRequestVerificationId, accepted: false);
                    }
                  : null,
              child: CustomTextView(
                label: 'Reject',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: OQDOThemeData.blackColor,
                    ),
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 70.0,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF006590)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: Color(0xFF006590),
                    ),
                  ),
                ),
              ),
              onPressed: selectedRequestVerificationId != null
                  ? () {
                      updateFacilityBookingRefundStatus(verificationId: selectedRequestVerificationId, accepted: true);
                    }
                  : null,
              child: CustomTextView(
                label: 'Accept',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16.0, color: OQDOThemeData.whiteColor),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> getTransaction(String facilityProviderId, bool clearList) async {
    setState(() {
      isLoading = true;
      if (clearList) {
        cancellationRequestList.clear();
      }
    });
    try {
      String requestStr = 'FacilityProviderId=$facilityProviderId&Page&PageStart=$pageCount&ResultPerPage=$resultPerPage';
      CancellationRequestsListModel cancellationRequestListResponse =
          await Provider.of<ServiceProvidersCancellationViewModel>(context, listen: false).getFacilityTransactionList(requestStr);
      if (!mounted) return;

      if (cancellationRequestListResponse.data != null && cancellationRequestListResponse.data!.isNotEmpty) {
        setState(() {
          isLoading = false;
          cancellationRequestList.addAll(cancellationRequestListResponse.data!);
          totalCount = cancellationRequestListResponse.totalCount!;
        });
        if (cancellationRequestList.isNotEmpty) {
          for (var cancellationRequest in cancellationRequestList) {
            if (cancellationRequest.expiredAt != null && cancellationRequest.expiredAt != null) {
              var expireTime = DateTime.parse(convertUtcToSgt(cancellationRequest.expiredAt.toString()));
              var currentTime = DateTime.now();
              var duration = expireTime.difference(currentTime);
              if (duration.inMilliseconds != 0 && !duration.inMilliseconds.isNegative) {
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
            cancellationRequest.expireTimeController?.start();
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on CommonException catch (error) {
      showLog('common $error');
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

  Future<void> updateFacilityBookingRefundStatus({int? verificationId, required bool accepted}) async {
    await _progressDialog.show();
    Map request = {"BookingRefundVerificationId": verificationId, "Status": accepted ? "A" : "R"};
    try {
      var response = await Provider.of<ServiceProvidersCancellationViewModel>(context, listen: false).updateFacilityBookingRefundStatus(request);
      if (!mounted) return;
      if (response.isNotEmpty) {
        showSnackBarColor('Request ${accepted ? "accepted" : "rejected"} successfully', context, false);
        Future.delayed(const Duration(seconds: 1), () async {
          await _progressDialog.hide();
          cancellationRequestList.clear();
          await getTransaction(OQDOApplication.instance.facilityID!, true);
        });
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on CommonException catch (error) {
      showLog('common $error');
      if (!mounted) return;
      await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      await _progressDialog.hide();
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
