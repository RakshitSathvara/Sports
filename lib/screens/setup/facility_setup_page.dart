// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/facility_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/grid_view_item_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/create_facility_setup_page.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/facility_training_preview_page.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/facility_list_response_model.dart';
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
        backgroundColor: Theme.of(context).extension<CustomColors>()!.greyButton,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, CreateFacilitySetupPage.routeName);
          if (result == true) {
            Future.delayed(const Duration(milliseconds: 200), () {
              getFacilitySetupList(showLoader: false);
            });
          }
          // await Navigator.pushNamed(context, Constants.ADDFACILITYPAGE).then((value) {
          //   if (value != null) {
          //     Future.delayed(const Duration(milliseconds: 200), () {
          //       getFacilitySetupList();
          //     });
          //   }
          // });
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
                        Theme.of(context).extension<CustomColors>()!.greyButton,
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

  void getFacilitySetupList({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
        _progressDialog.style(message: "Please wait..");
        _progressDialog.show();
      }
      FacilityListResponseModel facilityListResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilitySetupList(OQDOApplication.instance.facilityID!);
      if (showLoader) {
        _progressDialog.hide();
      }
      setState(() {});
      facilitySetupList = facilityListResponseModel.data!;
      debugPrint(facilityListResponseModel.data!.toString());
    } on NoConnectivityException catch (_) {
      if (showLoader) {
        _progressDialog.hide();
      }
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      if (showLoader) {
        _progressDialog.hide();
      }
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
      final result = await Navigator.pushNamed(context, CreateFacilitySetupPage.routeName, arguments: getFacilityByIdModel);
      if (result == true) {
        getFacilitySetupList();
      }
      // await Navigator.of(context).pushNamed(Constants.editFacilitySetup, arguments: getFacilityByIdModel).then((value) {
      //   if (value != null) {
      //     getFacilitySetupList();
      //   }
      // });
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
      // Convert GetFacilityByIdModel to FacilityPreviewModel
      FacilityPreviewModel facilityPreviewModel = _convertToFacilityPreviewModel(getFacilityByIdModel);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FacilityTrainingPreviewPage(facilityDetails: facilityPreviewModel),
        ),
      );
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

  FacilityPreviewModel _convertToFacilityPreviewModel(GetFacilityByIdModel model) {
    // Convert slots to AddTimeSlotModel list
    List<AddTimeSlotModel> slotsList = [];

    if (model.slots != null) {
      for (Slots slot in model.slots!) {
        // Convert day numbers to GridViewItemModel list
        List<GridViewItemModel> selectedDays = [];
        if (slot.dayNos != null) {
          for (int dayNo in slot.dayNos!) {
            String dayName = _getDayName(dayNo);
            selectedDays.add(GridViewItemModel(id: dayNo, imagePath: "", title: dayName));
          }
        }

        // Create controllers for the AddTimeSlotModel
        TextEditingController startTimeController = TextEditingController(text: slot.startTimeFormatted ?? '00:00');
        TextEditingController numberOfSlotsController = TextEditingController(text: (slot.noOfSlot ?? 1).toString());

        AddTimeSlotModel timeSlotModel = AddTimeSlotModel(
          selectedDays: selectedDays,
          startTime: startTimeController,
          formKey: GlobalKey<FormState>(),
          numberOfSlots: numberOfSlotsController,
          perSlotDuration: int.tryParse(model.slotTimeHour ?? '1') ?? 1,
          startTimeControllerKey: GlobalKey(),
          ratePerHour: slot.ratePerHour ?? model.ratePerHour ?? 0.0,
          startTimeFormatted: slot.startTimeFormatted,
          endTimeFormatted: slot.endTimeFormatted,
        );

        slotsList.add(timeSlotModel);
      }
    }

    // Determine if it's private rental based on booking type
    bool isPrivateRental = model.bookingType == 'I' ? true : false;

    // Calculate slot duration for display
    String slotDuration = '';
    if (model.slotTimeHour != null && model.slotTimeMinute != null) {
      int slotHours = int.tryParse(model.slotTimeHour!) ?? 0;
      int totalMinutes = (slotHours * 60) + (model.slotTimeMinute ?? 0);
      if (totalMinutes >= 60) {
        int hours = totalMinutes ~/ 60;
        int minutes = totalMinutes % 60;
        if (minutes > 0) {
          slotDuration = '${hours}h ${minutes}m';
        } else {
          slotDuration = '${hours}h';
        }
      } else {
        slotDuration = '${totalMinutes}m';
      }
    } else if (model.slotTimeHour != null) {
      slotDuration = '${model.slotTimeHour}h';
    }

    // Calculate rental duration in minutes
    int slotHours = int.tryParse(model.slotTimeHour ?? '1') ?? 1;
    int rentalDurationInMinutes = (slotHours * 60) + (model.slotTimeMinute ?? 0);

    return FacilityPreviewModel(
      title: model.title ?? '',
      subTitle: model.subTitle ?? '',
      activity: model.activityName ?? '',
      subActivity: model.subActivityName ?? '',
      description: model.description ?? '',
      slotDuration: slotDuration,
      rentalDurationInMinutes: rentalDurationInMinutes,
      slotRate: model.ratePerHour ?? 0.0,
      maxCapacityOrGroupSize: model.bookingType == "I" ? (model.facilityCapacity?.toString() ?? '1') : (model.maxGroupSize?.toString() ?? '1'),
      isPrivateRental: isPrivateRental,
      slotsList: slotsList,
    );
  }

  String _getDayName(int dayNo) {
    switch (dayNo) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 0:
        return 'Sun';
      default:
        return 'Unknown';
    }
  }
}
