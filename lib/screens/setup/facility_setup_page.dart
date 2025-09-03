// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/facility_list_response_model.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/service_provider_setup_viewmodel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/GetFacilityByIdModel.dart';
import '../../oqdo_application.dart';

class FacilitySetupPage extends StatefulWidget {
  const FacilitySetupPage({Key? key}) : super(key: key);

  @override
  FacilitySetupPageState createState() => FacilitySetupPageState();
}

class FacilitySetupPageState extends State<FacilitySetupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;

  late ProgressDialog _progressDialog;
  List<Data> facilitySetupList = [];

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFacilitySetupList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Facility Setup',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        backgroundColor: ColorsUtils.greyButton,
        onPressed: () async {
          await Navigator.pushNamed(context, Constants.ADDFACILITYPAGE).then((value) {
            if (value != null) {
              Future.delayed(const Duration(milliseconds: 200), () {
                getFacilitySetupList();
              });
            }
          });
        },
        // isExtended: true,
        child: Icon(
          Icons.add_rounded,
          size: 50,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.onBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: facilitySetupList.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: facilitySetupList.length,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextView(
                                        textOverFlow: TextOverflow.ellipsis,
                                        maxLine: 2,
                                        label: facilitySetupList[index].title!,
                                        type: styleSubTitle,
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          getFacilityDetailsById(facilitySetupList[index].facilitySetupId);
                                        },
                                        child: CustomTextView(
                                          label: 'Details',
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.shadow,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                decoration: TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        CalendarViewModel calendarViewModel = CalendarViewModel();
                                        calendarViewModel.facilitySetupId = facilitySetupList[index].facilitySetupId;
                                        calendarViewModel.selectedDateTime = DateTime.now();
                                        await Navigator.of(context).pushNamed(Constants.facilityCancelSlotScreen, arguments: calendarViewModel);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_cancel.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        callGetSetupById(facilitySetupList[index].facilitySetupId);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_edit.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showAlertDialog(context, facilitySetupList[index]);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_delete.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        })
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_setup_empty.png',
                            width: 400,
                            height: 400,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(text: 'There is nothing to show,\nadd Facilities from '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 25,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const TextSpan(text: ' icon below.'),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 18),
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, Constants.VACATIONLISTPAGE);
                  },
                  // icon: Icon(
                  //   Icons.add_rounded,
                  //   color: Theme.of(context).colorScheme.primary,
                  // ),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onBackground,
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        ColorsUtils.greyButton,
                      )),
                  child: Text(
                    "Vacation",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getFacilitySetupList() async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      _progressDialog.show();
      FacilityListResponseModel facilityListResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilitySetupList(OQDOApplication.instance.facilityID!);

      _progressDialog.hide();
      setState(() {});
      facilitySetupList = facilityListResponseModel.data!;
      debugPrint(facilityListResponseModel.data!.toString());
    } on NoConnectivityException catch (_) {
      _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      _progressDialog.hide();
      debugPrint(error.toString());
      // showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void _showAlertDialog(BuildContext context, Data facilitySetupList) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Facility Setup'),
        content: const Text('Are you sure you want to delete this Facility Setup?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              deleteFacilitySetupCall(facilitySetupList);
            },
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }

  Future<void> deleteFacilitySetupCall(Data facilitySetupList) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      Map deleteFacilitySetupRequestMap = {};
      deleteFacilitySetupRequestMap['FacilitySetupId'] = facilitySetupList.facilitySetupId!.toString();
      debugPrint(json.encode(deleteFacilitySetupRequestMap));
      var response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).deleteFacilitySetup(deleteFacilitySetupRequestMap);
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Delete successfully', context, false);

        Future.delayed(const Duration(milliseconds: 200), () {
          getFacilitySetupList();
        });
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
      debugPrint(response);
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
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
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
    }
  }

  Future<void> callGetSetupById(int? facilitySetupId) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      GetFacilityByIdModel getFacilityByIdModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilityById(facilitySetupId!);
      await _progressDialog.hide();
      debugPrint(getFacilityByIdModel.title);
      await Navigator.of(context).pushNamed(Constants.editFacilitySetup, arguments: getFacilityByIdModel).then((value) {
        if (value != null) {
          getFacilitySetupList();
        }
      });
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
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
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
    }
  }

  Future<void> getFacilityDetailsById(int? facilityId) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      GetFacilityByIdModel getFacilityByIdModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilityById(facilityId!);
      await _progressDialog.hide();
      debugPrint(getFacilityByIdModel.title);
      await Navigator.of(context).pushNamed(Constants.facilityDetailsScreen, arguments: getFacilityByIdModel);
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
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
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
    }
  }
}
