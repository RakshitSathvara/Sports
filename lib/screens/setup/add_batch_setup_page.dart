// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/coach_training_address.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/add_facility_slot_model.dart';
import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../theme/oqdo_theme_data.dart';
import '../../utils/constants.dart';
import '../../utils/utilities.dart';
import '../../viewmodels/service_provider_setup_viewmodel.dart';
import 'setups_bottom_sheets/Show24HrsAleartBottomSheet.dart';
import 'setups_bottom_sheets/ShowClearSlotsBottomSheet.dart';

class AddBatchSetupPage extends StatefulWidget {
  const AddBatchSetupPage({Key? key}) : super(key: key);

  @override
  AddBatchSetupPageState createState() => AddBatchSetupPageState();
}

class AddBatchSetupPageState extends State<AddBatchSetupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController slotRateController = TextEditingController();
  TextEditingController hourfirst = TextEditingController();
  TextEditingController hoursecond = TextEditingController();
  TextEditingController minutefirst = TextEditingController();
  TextEditingController minutesecond = TextEditingController();
  bool _monday = false;
  bool _tuesday = false;
  bool _wednesday = false;
  bool _thurday = false;
  bool _friday = false;
  bool _saturday = false;
  bool _sunday = false;
  bool _isTrainingAddress = false;
  bool _isTraineeAddress = false;
  bool _isSameRatesForSlots = true;
  bool isSlotTimeChangeRequestAccepted = true;
  String? choosedinterest;
  String? choosediActivity;
  String? choosedAddress;
  late String bookingType;
  late Helper hp;

  List<ActivityBean> activityListModel = [];
  List<ActivityBean> subActivity = [];
  String? selectedSubActivityID = '';
  late ProgressDialog _progressDialog;
  final Duration _defaultSlotDuration = const Duration(hours: 00, minutes: 60);
  int _slotTimeInMins = 60;
  List<int> slotListData = [];
  TextEditingController person = TextEditingController();
  final groupSizeController = TextEditingController();
  List<AddFacilitySlotModel>? addFacilitySlotList = [];
  int? slotTime = 0;
  List<CoachTrainingAddress>? coachTrainingAddressList = [];
  final TextEditingController _buildingName = TextEditingController();
  final TextEditingController _address1 = TextEditingController();
  final TextEditingController _address2 = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  String? cityID = '';
  List<int> selectedAddress = [];
  String selectedAddressId = '';
  late String addressType;
  String? selectedActivityID = '';
  int? finalSlotTime = 0;
  bool isVenueShowForIndividualBooking = false;

  AddFacilitySlotModel mAddFacilitySlotModel = AddFacilitySlotModel();
  String selectedAddressFullName = '';
  List<String> minimumSlotList = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  String? selectedMinimumSlot = '';

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    setInitValue();
  }

  void setInitValue() {
    selectedMinimumSlot = minimumSlotList.first;
    bookingType = "I";
    addressType = '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getAllActivity();
      setSlotInintTime();
      // cityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
      cityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
      debugPrint('City id -> ${cityID!}');
    });
  }

  void setSlotInintTime() async {
    String finalTime = formatDuration(_defaultSlotDuration);
    debugPrint('Init Slot Time -> $finalTime');

    String hrs = finalTime.split(":")[0];
    String mins = finalTime.split(":")[1];
    String convertedHour = hrs.padLeft(2, '0');
    String convertedMinute = mins.padLeft(2, '0');

    hourfirst.text = convertedHour[0];
    hoursecond.text = convertedHour[1];
    minutefirst.text = convertedMinute[0];
    minutesecond.text = convertedMinute[1];

    for (int i = 1; i <= 24; i++) {
      slotListData.add(i);
    }

    person.addListener(() {
      if (person.text.toString().trim().isNotEmpty) {
        debugPrint('in if');
        if (bookingType == 'I') {
          if (person.text.toString().trim().compareTo('1') == 0) {
            setState(() {
              addressType = '';
              _isTraineeAddress = false;
              _isTrainingAddress = false;
              isVenueShowForIndividualBooking = true;
            });
          } else {
            setState(() {
              isVenueShowForIndividualBooking = false;
              _isTraineeAddress = false;
              _isTrainingAddress = false;
              addressType = '';
            });
          }
        } else {
          setState(() {
            isVenueShowForIndividualBooking = false;
            _isTraineeAddress = false;
            _isTrainingAddress = false;
            addressType = '';
          });
        }
      } else {
        setState(() {
          debugPrint('in else');
          isVenueShowForIndividualBooking = false;
          _isTraineeAddress = false;
          _isTrainingAddress = false;
          addressType = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Add Batch Setup',
        onBack: () {
          Navigator.pop(context);
        },
        actions: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (selectedActivityID!.isEmpty) {
                showSnackBar('Please select Activity', context);
              } else if (selectedSubActivityID!.isEmpty) {
                showSnackBar('Please select Sub-Activity', context);
              } else if (_slotTimeInMins < 60) {
                showSnackBar('Slot time can not less than 60 minutes', context);
              } else if (_slotTimeInMins > 720) {
                showSnackBar('Slot time must be less than 12 hours', context);
              } else if (nameController.text.toString().trim().isEmpty) {
                showSnackBar('Name required', context);
              } else if (person.text.toString().trim().isEmpty) {
                showSnackBar('Batch capacity person required', context);
              } else if (person.text.toString().trim().isNotEmpty && (double.parse(person.text.trim()) < 1)) {
                showSnackBar('Batch capacity person must be greater than 0', context);
              } else if (bookingType == 'G' && groupSizeController.text.trim().isEmpty) {
                showSnackBar('Max group size required', context);
              } else if (bookingType == 'G' && int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim()) == 0) {
                showSnackBar('Max group size must be greater than 0', context);
              } else if (_isSameRatesForSlots && priceController.text.toString().trim().isEmpty) {
                showSnackBar('Rate required', context);
              } else if (_isSameRatesForSlots && priceController.text.toString().trim().isNotEmpty && (double.parse(priceController.text.trim()) < 1)) {
                showSnackBar('Rate/hour should be greater than or equals to 1', context);
              } else if (_isTrainingAddress && selectedAddressId.isEmpty) {
                showSnackBar('Please select training address', context);
              } else if (addFacilitySlotList!.isEmpty) {
                showSnackBar('Please add slot', context);
              } else {
                validate();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 10),
              child: CustomTextView(
                label: 'Submit',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: activityListModel.isNotEmpty
            ? SingleChildScrollView(
                child: Form(
                  key: hp.formKey,
                  child: Container(
                    color: Theme.of(context).colorScheme.onBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                            child: CustomTextView(
                              label: "Activity Type - ${activityListModel[0].Name}",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.greyText),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color:
                          //             Theme.of(context).colorScheme.primaryContainer),
                          //     borderRadius: BorderRadius.circular(15),
                          //     color: Theme.of(context).colorScheme.onBackground,
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(left: 10, right: 10),
                          //     child: DropdownButton<dynamic>(
                          //         isExpanded: true,
                          //         underline: const SizedBox(),
                          //         borderRadius: BorderRadius.circular(15),
                          //         dropdownColor:
                          //             Theme.of(context).colorScheme.onBackground,
                          //         hint: Text(
                          //           "Select One",
                          //           style: Theme.of(context)
                          //               .textTheme
                          //               .titleSmall!
                          //               .copyWith(
                          //                   color: Theme.of(context)
                          //                       .colorScheme
                          //                       .primaryContainer),
                          //         ),
                          //         value: choosedinterest,
                          //         items: activityListModel.map((interest) {
                          //           return DropdownMenuItem(
                          //             child: Text(interest.Name!),
                          //             value: interest.Name,
                          //           );
                          //         }).toList(),
                          //         onChanged: (value) {
                          //           setState(() {
                          //             choosedinterest = value;
                          //             subActivity.clear();
                          //             choosediActivity = null;
                          //           });
                          //           print(choosedinterest);
                          //         }),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          subActivity.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                                    borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: DropdownButton<dynamic>(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        borderRadius: BorderRadius.circular(15),
                                        dropdownColor: Theme.of(context).colorScheme.onBackground,
                                        hint: Text(
                                          "Select One",
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                        ),
                                        value: choosediActivity,
                                        items: subActivity[0].SubActivities!.map((interest) {
                                          return DropdownMenuItem(
                                            value: interest.Name,
                                            child: Text(interest.Name!),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            choosediActivity = value as String;
                                          });
                                          debugPrint(choosediActivity);
                                          getSubActivityID();
                                        }),
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 28,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: RadioListTile(
                                    visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                                    value: bookingType,
                                    groupValue: 'I',
                                    title: CustomTextView(
                                      maxLine: 2,
                                      label: 'Individual Booking',
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 18),
                                    ),
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        bookingType = 'I';
                                        person.text = '';
                                        groupSizeController.clear();
                                        addressType = '';
                                        _isTraineeAddress = false;
                                        _isTrainingAddress = false;
                                      });
                                    }),
                              ),
                              Expanded(
                                child: RadioListTile(
                                    visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                                    value: bookingType,
                                    groupValue: 'G',
                                    title: CustomTextView(
                                      maxLine: 2,
                                      label: 'Group Booking',
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 18),
                                    ),
                                    activeColor: Theme.of(context).colorScheme.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        bookingType = 'G';
                                        person.text = "1";
                                        addressType = '';
                                        _isTraineeAddress = false;
                                        _isTrainingAddress = false;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          CustomTextFormField(
                            controller: nameController,
                            read: false,
                            obscureText: false,
                            labelText: 'Name',
                            maxlength: 50,
                            maxlines: 1,
                            validator: Validator.notEmpty,
                            keyboardType: TextInputType.text,
                          ),
                          bookingType != 'G'
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 28,
                                    ),
                                    CustomTextFormField(
                                      controller: person,
                                      read: bookingType == 'G' ? true : false,
                                      obscureText: false,
                                      inputformat: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxlines: 1,
                                      maxlength: 4,
                                      labelText: 'Batch Capacity (Person)',
                                      validator: Validator.notEmpty,
                                      keyboardType: const TextInputType.numberWithOptions(signed: true),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 28,
                          ),
                          bookingType == 'G'
                              ? CustomTextFormField(
                                  controller: groupSizeController,
                                  read: false,
                                  obscureText: false,
                                  inputformat: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                  maxlines: 1,
                                  maxlength: 3,
                                  labelText: 'Max size of the group',
                                  validator: (value) {
                                    if (value?.isEmpty ?? false) {
                                      return "Required field";
                                    } else if (int.parse(value ?? "0") == 0) {
                                      return "Value must be greater than 0";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                )
                              : const SizedBox(),
                          SizedBox(
                            height: bookingType == 'G' ? 20 : 0,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                  value: _isSameRatesForSlots,
                                  activeColor: Theme.of(context).colorScheme.primary,
                                  onChanged: (val) {
                                    if (addFacilitySlotList?.isNotEmpty ?? false) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Slot Booking'),
                                          content: const Text(
                                              'Are you sure you want to change rates settings?\n\nIf you change now it\'ll remove all added slots.\n\nPlease note that this action can\'t be reversed.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('No, Continue Setup'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                priceController.clear();
                                                slotRateController.clear();
                                                addFacilitySlotList?.clear();
                                                isSlotTimeChangeRequestAccepted = false;
                                                setState(() {
                                                  _isSameRatesForSlots = val!;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Yes, Change settings'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      priceController.clear();
                                      slotRateController.clear();
                                      setState(() {
                                        _isSameRatesForSlots = val!;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              CustomTextView(
                                label: 'Same Rates for Slots',
                                type: styleSubTitle,
                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextView(
                            label: 'Minimum Slot',
                            textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: DropdownButton<String>(
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  borderRadius: BorderRadius.circular(15),
                                  dropdownColor: Theme.of(context).colorScheme.onBackground,
                                  hint: Text(
                                    "Select Slot",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                  ),
                                  value: selectedMinimumSlot,
                                  items: minimumSlotList.map((interest) {
                                    return DropdownMenuItem(
                                      value: interest.toString(),
                                      child: Text(interest),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMinimumSlot = value as String;
                                    });
                                    debugPrint(selectedMinimumSlot);
                                    // getSubActivityID();
                                  }),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: priceController,
                                  read: !_isSameRatesForSlots,
                                  enabled: _isSameRatesForSlots,
                                  maxlength: 6,
                                  obscureText: false,
                                  labelText: 'Rate/hour (S\$)',
                                  inputformat: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  maxlines: 1,
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return "Required field";
                                    } else if (double.parse(value) < 1) {
                                      return "Rate/hour should be greater than or equals to 1";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  onchanged: (changedVal) => _onChangeSlotRatesPerHour(changedVal) ?? '',
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CustomTextView(
                                            label: "Slot Time",
                                            type: styleSubTitle,
                                            textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                  color: ColorsUtils.greyText,
                                                ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              setSlotValue();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                              child: Image.asset(
                                                "assets/images/pick_time.png",
                                                height: 25,
                                                width: 25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                            child: TextField(
                                              controller: hourfirst,
                                              readOnly: !isSlotTimeChangeRequestAccepted,
                                              autofocus: false,
                                              style: const TextStyle(fontSize: 12),
                                              keyboardType: TextInputType.number,
                                              maxLength: 1,
                                              onChanged: (val) {
                                                if (val.isNotEmpty) {
                                                  FocusScope.of(context).nextFocus();
                                                }
                                              },
                                              onTap: () {
                                                if (!isSlotTimeChangeRequestAccepted && (addFacilitySlotList?.isNotEmpty ?? false)) {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isDismissible: false,
                                                      enableDrag: false,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(20),
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      backgroundColor: OQDOThemeData.whiteColor,
                                                      builder: (BuildContext context) => const ShowClearSlotsBottomSheet()).then((value) {
                                                    if (value != null) {
                                                      bool data = value as bool;
                                                      if (data) {
                                                        addFacilitySlotList?.clear();
                                                        setState(() {
                                                          isSlotTimeChangeRequestAccepted = true;
                                                        });
                                                      }
                                                    }
                                                  });
                                                }
                                              },
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                counterText: '',
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                            child: TextField(
                                              controller: hoursecond,
                                              readOnly: !isSlotTimeChangeRequestAccepted,
                                              autofocus: false,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 12),
                                              keyboardType: TextInputType.number,
                                              maxLength: 1,
                                              onChanged: (val) {
                                                if (val.isNotEmpty) {
                                                  FocusScope.of(context).unfocus();
                                                } else {
                                                  FocusScope.of(context).previousFocus();
                                                }
                                              },
                                              onTap: () {
                                                if (!isSlotTimeChangeRequestAccepted && (addFacilitySlotList?.isNotEmpty ?? false)) {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isDismissible: false,
                                                      enableDrag: false,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(20),
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      backgroundColor: OQDOThemeData.whiteColor,
                                                      builder: (BuildContext context) => const ShowClearSlotsBottomSheet()).then((value) {
                                                    if (value != null) {
                                                      bool data = value as bool;
                                                      if (data) {
                                                        addFacilitySlotList?.clear();
                                                        setState(() {
                                                          isSlotTimeChangeRequestAccepted = true;
                                                        });
                                                      }
                                                    }
                                                  });
                                                }
                                              },
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                counterText: '',
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        CustomTextView(
                                          label: ":",
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.labelLarge,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                            child: TextField(
                                              controller: minutefirst,
                                              readOnly: !isSlotTimeChangeRequestAccepted,
                                              autofocus: false,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 12),
                                              keyboardType: TextInputType.number,
                                              maxLength: 1,
                                              onChanged: (val) {
                                                if (val.isNotEmpty) {
                                                  FocusScope.of(context).nextFocus();
                                                }
                                              },
                                              onTap: () {
                                                if (!isSlotTimeChangeRequestAccepted && (addFacilitySlotList?.isNotEmpty ?? false)) {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isDismissible: false,
                                                      enableDrag: false,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(20),
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      backgroundColor: OQDOThemeData.whiteColor,
                                                      builder: (BuildContext context) => const ShowClearSlotsBottomSheet()).then((value) {
                                                    if (value != null) {
                                                      bool data = value as bool;
                                                      if (data) {
                                                        addFacilitySlotList?.clear();
                                                        setState(() {
                                                          isSlotTimeChangeRequestAccepted = true;
                                                        });
                                                      }
                                                    }
                                                  });
                                                }
                                              },
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                counterText: '',
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                            child: TextField(
                                              controller: minutesecond,
                                              readOnly: !isSlotTimeChangeRequestAccepted,
                                              autofocus: false,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 12),
                                              keyboardType: TextInputType.number,
                                              maxLength: 1,
                                              onChanged: (val) {
                                                if (val.isNotEmpty) {
                                                  FocusScope.of(context).unfocus();
                                                } else {
                                                  FocusScope.of(context).previousFocus();
                                                }
                                              },
                                              onTap: () {
                                                if (!isSlotTimeChangeRequestAccepted && (addFacilitySlotList?.isNotEmpty ?? false)) {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isDismissible: false,
                                                      enableDrag: false,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(20),
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      backgroundColor: OQDOThemeData.whiteColor,
                                                      builder: (BuildContext context) => const ShowClearSlotsBottomSheet()).then((value) {
                                                    if (value != null) {
                                                      bool data = value as bool;
                                                      if (data) {
                                                        addFacilitySlotList?.clear();
                                                        setState(() {
                                                          isSlotTimeChangeRequestAccepted = true;
                                                        });
                                                      }
                                                    }
                                                  });
                                                }
                                              },
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                counterText: '',
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                            child: CustomTextView(
                              label: "Training Venue",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: ColorsUtils.greyText),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                            child: Row(
                              children: [
                                bookingType == 'I' && !isVenueShowForIndividualBooking
                                    ? SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Radio(
                                          value: addressType,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          groupValue: '1',
                                          activeColor: Theme.of(context).colorScheme.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              addressType = '1';
                                              _isTrainingAddress = true;
                                              _isTraineeAddress = false;
                                            });
                                          },
                                        ),
                                      )
                                    : SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Checkbox(
                                          value: _isTrainingAddress,
                                          activeColor: Theme.of(context).colorScheme.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              _isTrainingAddress = val!;
                                            });
                                          },
                                        ),
                                      ),
                                const SizedBox(width: 8.0),
                                CustomTextView(
                                  label: 'Training Address',
                                  type: styleSubTitle,
                                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _isTrainingAddress,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(26.0, 4, 12, 8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                                            borderRadius: BorderRadius.circular(15),
                                            color: Theme.of(context).colorScheme.onBackground,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            child: DropdownButton<dynamic>(
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                borderRadius: BorderRadius.circular(15),
                                                dropdownColor: Theme.of(context).colorScheme.onBackground,
                                                hint: Text(
                                                  "Add/Select Address",
                                                  style:
                                                      Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primaryContainer),
                                                ),
                                                value: choosedAddress,
                                                items: coachTrainingAddressList!.map((addressItem) {
                                                  return DropdownMenuItem(
                                                    value: addressItem.addressName,
                                                    child: StatefulBuilder(
                                                      builder: (context, newState) {
                                                        return Text(
                                                          addressItem.addressName!,
                                                          maxLines: 2,
                                                          style: const TextStyle(color: OQDOThemeData.blackColor, fontWeight: FontWeight.w400, fontSize: 15.0),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    choosedAddress = value;
                                                    getAddressFromSelectedAddress();
                                                    setFullAddressFromSelectedAddress();
                                                  });
                                                  debugPrint(choosedAddress);
                                                }),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isDismissible: true,
                                            isScrollControlled: true,
                                            builder: (ctx) => _buildAddTrainingAddressBottomSheet(ctx),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                            )).then((value) {
                                          if (value != null) {
                                            _buildingName.text = '';
                                            _address1.text = '';
                                            _address2.text = '';
                                            _pincode.text = '';
                                            Map addressData = value as Map;
                                            debugPrint(addressData.toString());
                                            addCoachTrainingAddress(addressData);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                        child: Image.asset(
                                          "assets/images/circle_add.png",
                                          height: 35,
                                          width: 35,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                selectedAddressFullName.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(left: 20, right: 20),
                                        child: CustomTextView(
                                          maxLine: 4,
                                          textOverFlow: TextOverflow.ellipsis,
                                          label: 'Address : $selectedAddressFullName',
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                            child: Row(
                              children: [
                                bookingType == 'I' && !isVenueShowForIndividualBooking
                                    ? Visibility(
                                        visible: _isTraineeAddress,
                                        child: SizedBox(
                                          height: 50.0,
                                          width: 50.0,
                                          child: Radio(
                                            value: addressType,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            groupValue: '2',
                                            activeColor: Theme.of(context).colorScheme.primary,
                                            onChanged: (val) {
                                              setState(() {
                                                addressType = '2';
                                                _isTrainingAddress = false;
                                                _isTraineeAddress = true;
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Checkbox(
                                          value: _isTraineeAddress,
                                          activeColor: Theme.of(context).colorScheme.primary,
                                          onChanged: (val) {
                                            setState(() {
                                              _isTraineeAddress = val!;
                                              if (val!) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Alert'),
                                                    content: const Text(
                                                        'While creating coaching slots ensure sufficient time gap between two slots for your rest and travel time (particularly if training at trainee place)!'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Ok'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                const SizedBox(width: 8.0),
                                bookingType == 'I' && !isVenueShowForIndividualBooking
                                    ? Visibility(
                                        visible: _isTraineeAddress,
                                        child: CustomTextView(
                                          label: 'Trainee Address',
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                        ),
                                      )
                                    : CustomTextView(
                                        label: 'Trainee Address',
                                        type: styleSubTitle,
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: CustomTextView(
                                      label: "Add Slot",
                                      type: styleSubTitle,
                                      textStyle: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _slotTimeInMins = Duration(
                                          hours:
                                              int.parse("${hourfirst.text.isEmpty ? "0" : hourfirst.text}${hoursecond.text.isEmpty ? "0" : hoursecond.text}"),
                                          minutes: int.parse(
                                              "${minutefirst.text.isEmpty ? "0" : minutefirst.text}${minutesecond.text.isEmpty ? "0" : minutesecond.text}"))
                                      .inMinutes;
                                  if (_isSameRatesForSlots && priceController.text.isEmpty) {
                                    showSnackBar('Rate required', context);
                                  } else if (_isSameRatesForSlots && double.parse(priceController.text) < 1) {
                                    showSnackBar('Rate/hour should be greater than or equals to 1', context);
                                  } else if (_slotTimeInMins < 60) {
                                    showSnackBar('Slot time can not less than 60 minutes', context);
                                  } else if (_slotTimeInMins > 720) {
                                    showSnackBar('Slot time must be less than 12 hours', context);
                                  } else {
                                    mAddFacilitySlotModel = AddFacilitySlotModel();
                                    _monday = false;
                                    _tuesday = false;
                                    _wednesday = false;
                                    _thurday = false;
                                    _friday = false;
                                    _saturday = false;
                                    _sunday = false;
                                    showModalBottomSheet(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                        ),
                                        context: context,
                                        isDismissible: false,
                                        isScrollControlled: true,
                                        builder: (BuildContext ctx) {
                                          return _buildAddFacilityBottomSheet(ctx);
                                        }).then((value) => {
                                          if (value != null)
                                            {
                                              setState(() {
                                                addFacilitySlotList!.add(value);
                                                isSlotTimeChangeRequestAccepted = false;
                                                debugPrint("On Submit -> ${addFacilitySlotList!.length}");
                                                debugPrint("ON submit Slot ->${addFacilitySlotList![0].slotsModelList!.length}");
                                              })
                                            }
                                        });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  child: Image.asset(
                                    "assets/images/circle_add.png",
                                    height: 35,
                                    width: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          addFacilitySlotList!.isNotEmpty ? createSlotList() : Container(),
                          const SizedBox(
                            height: 20,
                          ),
                          // MyButton(
                          //   text: "Submit",
                          //   textcolor: Theme.of(context).colorScheme.onBackground,
                          //   textsize: 16,
                          //   fontWeight: FontWeight.w600,
                          //   letterspacing: 0.7,
                          //   buttoncolor:
                          //       Theme.of(context).colorScheme.secondaryContainer,
                          //   buttonbordercolor:
                          //       Theme.of(context).colorScheme.secondaryContainer,
                          //   buttonheight: 60,
                          //   buttonwidth: width,
                          //   radius: 15,
                          //   onTap: () async {
                          //     if (hp.formKey.currentState!.validate()) {
                          //       validate();
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  createSlotList() {
    return ListView.builder(
      key: UniqueKey(),
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, position) {
        // AddSlotModel addSlotModel = addSlotList[position];
        AddFacilitySlotModel addFacilitySlotModel = addFacilitySlotList![position];
        return createSlotListItem(context, addFacilitySlotModel, position);
      },
      itemCount: addFacilitySlotList!.length,
    );
  }

  createSlotListItem(BuildContext ctx, AddFacilitySlotModel addFacilitySlotModel, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.sunday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'S',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.sunday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.monday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'M',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.monday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.tuesday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'T',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.tuesday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.wednesday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'W',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color:
                                        addFacilitySlotModel.wednesday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.thursday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'T',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.thursday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.friday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'F',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.friday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: addFacilitySlotModel.saturday! ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                              child: Text(
                                'S',
                                style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: addFacilitySlotModel.saturday! ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                      child: IconButton(
                        onPressed: () {
                          addFacilitySlotList!.removeAt(index);
                          if (addFacilitySlotList?.isEmpty ?? true) {
                            isSlotTimeChangeRequestAccepted = true;
                          }
                          setState(() {});
                        },
                        icon: ImageIcon(
                          const AssetImage("assets/images/ic_delete.png"),
                          color: ColorsUtils.redDeleteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: CustomTextView(
                    label: "S\$ ${addFacilitySlotModel.ratePerHour?.toStringAsFixed(2) ?? 0}/hour",
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                    maxLine: 4,
                    textOverFlow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8, 0, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    CustomTextView(
                      label: "Start Time",
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(
                      width: 100,
                    ),
                    CustomTextView(
                      label: "End Time",
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(
                      width: 48,
                    ),
                  ],
                ),
              ),
              createTimeSlotList(addFacilitySlotModel.slotsModelList),
            ],
          ),
        ),
      ),
    );
  }

  createTimeSlotList(List<SlotsModel>? slotList) {
    // print('Length >>> ' + slotList.slotList![index].totalSlot.toString());
    return ListView.separated(
      key: UniqueKey(),
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, position) {
        SlotsModel slotModel = slotList![position];
        return createTimeSlotListItem(context, slotModel);
      },
      itemCount: slotList!.length,
      separatorBuilder: (context, position) {
        return const Divider(
          indent: 16, // empty space to the leading edge of divider.
          endIndent: 16,
        );
      },
    );
  }

  createTimeSlotListItem(BuildContext ctx, SlotsModel slotsModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                CustomTextView(
                    label: slotsModel.startTime.toString(),
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                const SizedBox(
                  width: 55,
                ),
                SizedBox(
                  height: 15,
                  child: ImageIcon(
                    const AssetImage("assets/images/arrow_right.png"),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(
                  width: 55,
                ),
                CustomTextView(
                    label: slotsModel.endTime.toString(),
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
            child: Text("${slotsModel.slots} Slots",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFacilityBottomSheet(BuildContext context) {
    // AddFacilitySlotModel mAddFacilitySlotModel = AddFacilitySlotModel();
    // mAddFacilitySlotModel.sunday = false;
    // mAddFacilitySlotModel.monday = false;
    // mAddFacilitySlotModel.tuesday = false;
    // mAddFacilitySlotModel.wednesday = false;
    // mAddFacilitySlotModel.thursday = false;
    // mAddFacilitySlotModel.friday = false;
    // mAddFacilitySlotModel.saturday = false;
    // _monday = false;
    // _tuesday = false;
    // _wednesday = false;
    // _thurday = false;
    // _friday = false;
    // _saturday = false;
    // _sunday = false;
    return SafeArea(
      child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Add Slot", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, color: ColorsUtils.redColor)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextView(
                          label: "Days Capacity",
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                      CustomTextView(
                          label: "Select Days", textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: ColorsUtils.greyText, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _sunday = _sunday ? false : true;
                            if (_sunday) {
                              mAddFacilitySlotModel.sunday = _sunday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(0);
                            } else {
                              mAddFacilitySlotModel.sunday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(0);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _sunday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'S',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _sunday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _monday = _monday ? false : true;
                            if (_monday) {
                              mAddFacilitySlotModel.monday = _monday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(1);
                            } else {
                              mAddFacilitySlotModel.monday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(1);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _monday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'M',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _monday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _tuesday = _tuesday ? false : true;
                            if (_tuesday) {
                              mAddFacilitySlotModel.tuesday = _tuesday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(2);
                            } else {
                              mAddFacilitySlotModel.tuesday = false;

                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(2);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _tuesday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'T',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _tuesday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _wednesday = _wednesday ? false : true;
                            if (_wednesday) {
                              mAddFacilitySlotModel.wednesday = _wednesday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(3);
                            } else {
                              mAddFacilitySlotModel.wednesday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(3);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _wednesday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'W',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _wednesday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _thurday = _thurday ? false : true;
                            if (_thurday) {
                              mAddFacilitySlotModel.thursday = _thurday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(4);
                            } else {
                              mAddFacilitySlotModel.thursday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(4);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _thurday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'T',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _thurday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _friday = _friday ? false : true;
                            if (_friday) {
                              mAddFacilitySlotModel.friday = _friday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(5);
                            } else {
                              mAddFacilitySlotModel.friday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(5);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _friday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'F',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _friday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _saturday = _saturday ? false : true;
                            if (_saturday) {
                              mAddFacilitySlotModel.saturday = _saturday;
                              mAddFacilitySlotModel.selectedSlotsDayList!.add(6);
                            } else {
                              mAddFacilitySlotModel.saturday = false;
                              mAddFacilitySlotModel.selectedSlotsDayList!.remove(6);
                            }
                          });
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _saturday ? Theme.of(context).colorScheme.primary : ColorsUtils.greyCircle,
                          child: Text(
                            'S',
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: _saturday ? Theme.of(context).colorScheme.onBackground : Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: CustomTextFormField(
                    controller: slotRateController,
                    read: _isSameRatesForSlots,
                    enabled: !_isSameRatesForSlots,
                    maxlength: 6,
                    obscureText: false,
                    labelText: 'Rate/hour (S\$)',
                    inputformat: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    maxlines: 1,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return "Required field";
                      } else if (double.parse(value) < 1) {
                        return "Rate/hour should be greater than or equals to 1";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: CustomTextView(label: "Time", textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: ColorsUtils.greyText, fontSize: 16)),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 26, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      CustomTextView(
                          label: "Start Time",
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                      const SizedBox(
                        width: 120,
                      ),
                      CustomTextView(
                          label: "End Time",
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                CustomTextView(
                                    label: mAddFacilitySlotModel.slotsModelList![position].startTime.toString(),
                                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                                const SizedBox(
                                  width: 16,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    var time = await showTimePicker(
                                      builder: (context, child) =>
                                          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                                    );

                                    if (time != null) {
                                      if (time.hour >= 22) {
                                        showSnackBar('Every slot must be end before 22:00', context);
                                      } else if (time.hour < 6) {
                                        showSnackBar('Every slot must be start after 6:00', context);
                                      } else {
                                        int hour = time.hour;
                                        int minute = time.minute;
                                        String convertedHour = hour.toString().padLeft(2, '0');
                                        String convertedMinute = minute.toString().padLeft(2, '0');

                                        if (mAddFacilitySlotModel.slotsModelList!.length > 1) {
                                          var mDateFormat = DateFormat('HH:mm');
                                          var currnetSelectedTime = mDateFormat.parse("$convertedHour:$convertedMinute");
                                          var previousEndTime = mDateFormat.parse(mAddFacilitySlotModel.slotsModelList![position - 1].endTime!);
                                          debugPrint(previousEndTime.toString());
                                          if (currnetSelectedTime.isBefore(previousEndTime)) {
                                            showSnackBar('Start time must be greater than end time', context);
                                          } else {
                                            if (mAddFacilitySlotModel.slotsModelList![position].slots != 0) {
                                              int startTimeHrs = hour * 60;
                                              int startTimeMinutes = minute;
                                              int finalStartTimeInMinutes = startTimeHrs + startTimeMinutes;
                                              int totalSlotTime = _slotTimeInMins * mAddFacilitySlotModel.slotsModelList![position].slots!;
                                              debugPrint('Total Slot time -> $totalSlotTime');
                                              debugPrint('Start time -> $finalStartTimeInMinutes');
                                              int endTimeMinutes = finalStartTimeInMinutes + totalSlotTime;
                                              debugPrint('End Time -> $endTimeMinutes');
                                              String endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                              debugPrint('End Time -> $endTime');
                                              mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                              mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                              mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                            }
                                            setState(() {
                                              mAddFacilitySlotModel.slotsModelList![position].startTime = "$convertedHour:$convertedMinute";
                                            });
                                          }
                                        } else {
                                          if (mAddFacilitySlotModel.slotsModelList![position].slots != 0) {
                                            int startTimeHrs = hour * 60;
                                            int startTimeMinutes = minute;
                                            int finalStartTimeInMinutes = startTimeHrs + startTimeMinutes;
                                            int totalSlotTime = _slotTimeInMins * mAddFacilitySlotModel.slotsModelList![position].slots!;
                                            debugPrint('Total Slot time -> $totalSlotTime');
                                            debugPrint('Start time -> $finalStartTimeInMinutes');
                                            int endTimeMinutes = finalStartTimeInMinutes + totalSlotTime;
                                            debugPrint('End Time -> $endTimeMinutes');
                                            String endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                            debugPrint('End Time -> $endTime');
                                            mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                            mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                            mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                          }
                                          setState(() {
                                            mAddFacilitySlotModel.slotsModelList![position].startTime = "$convertedHour:$convertedMinute";
                                          });
                                        }
                                      }
                                    }
                                  },
                                  child: SizedBox(
                                    height: 16,
                                    width: 40,
                                    child: ImageIcon(
                                      const AssetImage("assets/images/pick_time.png"),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                SizedBox(
                                  height: 15,
                                  child: ImageIcon(
                                    const AssetImage("assets/images/arrow_right.png"),
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                CustomTextView(
                                    label: mAddFacilitySlotModel.slotsModelList![position].endTime.toString(),
                                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                            child: GestureDetector(
                              child: Text('${mAddFacilitySlotModel.slotsModelList![position].slots} Slots',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      )),
                              onTap: () {
                                String? startTime = mAddFacilitySlotModel.slotsModelList![position].startTime;

                                if (mAddFacilitySlotModel.slotsModelList!.length > 1) {
                                  if (startTime == null || startTime == '00:00') {
                                    showSnackBar('Please select start time', context);
                                  } else {
                                    showModalBottomSheet(
                                        isDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return showPicker(context);
                                        }).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          debugPrint("slot data -> $value");
                                          int slot = value;
                                          TimeOfDay initEndTime = TimeOfDay(
                                              hour: int.parse(mAddFacilitySlotModel.slotsModelList![position].startTime!.split(':')[0]),
                                              minute: int.parse(mAddFacilitySlotModel.slotsModelList![position].startTime!.split(':')[1]));
                                          int startTimeHrs = initEndTime.hour * 60;
                                          int startTimeMinutes = initEndTime.minute;
                                          int finalStartTimeInMinutes = startTimeHrs + startTimeMinutes;
                                          int totalSlotTime = _slotTimeInMins * slot;

                                          //final check
                                          if (finalStartTimeInMinutes + totalSlotTime > 1320) {
                                            showSnackBar('Slot must be end on 22:00', context);
                                          } else {
                                            if (totalSlotTime > 1320 && finalSlotTime! >= 1320) {
                                              showSnackBar('Slot must be end on the same day', context);
                                            } else {
                                              if (finalSlotTime! > 1320) {
                                                showSnackBar('Slot must be end on the same day', context);
                                              } else {
                                                int endTimeMinutes = finalStartTimeInMinutes + totalSlotTime;
                                                if (finalSlotTime! > 0) {
                                                  if (endTimeMinutes <= 1320) {
                                                    mAddFacilitySlotModel.slotsModelList![position].slots = value;
                                                    String endTime = '';
                                                    if (endTimeMinutes == 1320) {
                                                      endTime = '21:59';
                                                    } else {
                                                      endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                                    }
                                                    debugPrint('End Time -> $endTime');
                                                    mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                                    mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                                    finalSlotTime = endTimeMinutes;
                                                    mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                                  } else {
                                                    showSnackBar('Slot must be end on the same day', context);
                                                  }
                                                } else {
                                                  mAddFacilitySlotModel.slotsModelList![position].slots = value;
                                                  String endTime = '';
                                                  if (endTimeMinutes == 1320) {
                                                    endTime = '21:59';
                                                  } else {
                                                    endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                                  }
                                                  debugPrint('End Time -> $endTime');
                                                  mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                                  mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                                  finalSlotTime = endTimeMinutes;
                                                  mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                                }
                                              }
                                            }
                                          }
                                        });
                                      }
                                    });
                                  }
                                } else {
                                  if (startTime == null || startTime == '00:00') {
                                    showSnackBar('Please select start time', context);
                                  } else {
                                    showModalBottomSheet(
                                        isDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return showPicker(context);
                                        }).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          debugPrint("slot data -> $value");
                                          int slot = value;
                                          TimeOfDay initEndTime = TimeOfDay(
                                              hour: int.parse(mAddFacilitySlotModel.slotsModelList![position].startTime!.split(':')[0]),
                                              minute: int.parse(mAddFacilitySlotModel.slotsModelList![position].startTime!.split(':')[1]));
                                          int startTimeHrs = initEndTime.hour * 60;
                                          int startTimeMinutes = initEndTime.minute;
                                          int finalStartTimeInMinutes = startTimeHrs + startTimeMinutes;
                                          int totalSlotTime = _slotTimeInMins * slot;

                                          //final check
                                          if (finalStartTimeInMinutes + totalSlotTime > 1320) {
                                            showSnackBar('Slot must be end on 22:00', context);
                                          } else {
                                            if (totalSlotTime > 1320) {
                                              showSnackBar('Slot must be end on the same day', context);
                                            } else {
                                              if (finalSlotTime! > 1320) {
                                                showSnackBar('Slot must be end on the same day', context);
                                              } else {
                                                int endTimeMinutes = finalStartTimeInMinutes + totalSlotTime;
                                                if (finalSlotTime! > 0) {
                                                  if (endTimeMinutes <= 1320) {
                                                    mAddFacilitySlotModel.slotsModelList![position].slots = value;
                                                    String endTime = '';
                                                    if (endTimeMinutes == 1320) {
                                                      endTime = '21:59';
                                                    } else {
                                                      endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                                    }
                                                    debugPrint('End Time -> $endTime');
                                                    mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                                    mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                                    finalSlotTime = endTimeMinutes;
                                                    mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                                  } else {
                                                    showSnackBar('Slot must be end on the same day', context);
                                                  }
                                                } else {
                                                  if (endTimeMinutes <= 1320) {
                                                    mAddFacilitySlotModel.slotsModelList![position].slots = value;
                                                    String endTime = '';
                                                    if (endTimeMinutes == 1320) {
                                                      endTime = '21:59';
                                                    } else {
                                                      endTime = getEndTimeInVisibleFormat(endTimeMinutes);
                                                    }
                                                    debugPrint('End Time -> $endTime');
                                                    mAddFacilitySlotModel.slotsModelList![position].endTime = endTime;
                                                    mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes = endTimeMinutes;
                                                    finalSlotTime = endTimeMinutes;
                                                    mAddFacilitySlotModel.slotsModelList![position].startTimeInMinutes = finalStartTimeInMinutes;
                                                  } else {
                                                    showSnackBar('Slot must be end on the same day', context);
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        });
                                      }
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                              child: Image.asset(
                                'assets/images/ic_delete.png',
                                width: 20.0,
                                height: 20.0,
                                color: OQDOThemeData.errorColor,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                finalSlotTime = finalSlotTime! - mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes!;
                                mAddFacilitySlotModel.slotsModelList!.removeAt(position);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: mAddFacilitySlotModel.slotsModelList!.length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      indent: 16,
                      endIndent: 16,
                    );
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                GestureDetector(
                  onTap: () {
                    if (mAddFacilitySlotModel.slotsModelList!.length > 24) {
                      showSnackBar('Can not add more slots', context);
                    } else {
                      if (finalSlotTime! >= 1320) {
                        showSnackBar('Slots full for the same day', context);
                      } else {
                        if (mAddFacilitySlotModel.slotsModelList!.isNotEmpty) {
                          var listLength = mAddFacilitySlotModel.slotsModelList!.length;
                          debugPrint(listLength.toString());
                          if (mAddFacilitySlotModel.slotsModelList![listLength - 1].slots == 0) {
                            showSnackBar('Please select slots', context);
                          } else {
                            setState(() {
                              mAddFacilitySlotModel.slotsModelList!.add(SlotsModel('00:00', '00:00', 0, 0, 0));
                            });
                          }
                        } else {
                          setState(() {
                            mAddFacilitySlotModel.slotsModelList!.add(SlotsModel('00:00', '00:00', 0, 0, 0));
                          });
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 8, 0),
                    child: Image.asset(
                      "assets/images/circle_add.png",
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        child: SimpleButton(
                          text: "Cancel",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 16,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: width,
                          radius: 15,
                          onTap: () async {
                            finalSlotTime = 0;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        child: SimpleButton(
                          text: "Submit",
                          textcolor: Theme.of(context).colorScheme.onBackground,
                          textsize: 16,
                          fontWeight: FontWeight.w600,
                          letterspacing: 0.7,
                          buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                          buttonheight: 60,
                          buttonwidth: width,
                          radius: 15,
                          onTap: () async {
                            List<SlotsModel> slotModelSlotData = mAddFacilitySlotModel.slotsModelList!.where((element) => element.slots == 0).toList();
                            debugPrint('Submit slot length -> ${slotModelSlotData.length}');
                            if (mAddFacilitySlotModel.selectedSlotsDayList!.isEmpty) {
                              showSnackBar('Please select days', context);
                            } else if (!_isSameRatesForSlots && slotRateController.text.isEmpty) {
                              showSnackBar('Rate required', context);
                            } else if (!_isSameRatesForSlots && double.parse(slotRateController.text) < 1) {
                              showSnackBar('Rate/hour should be greater than or equals to 1', context);
                            } else if (mAddFacilitySlotModel.slotsModelList!.isEmpty) {
                              showSnackBar('Please add slot', context);
                            } else if (slotModelSlotData.isNotEmpty) {
                              showSnackBar('Please select slot', context);
                            } else {
                              debugPrint(mAddFacilitySlotModel.toString());
                              finalSlotTime = 0;
                              mAddFacilitySlotModel.ratePerHour = double.parse(slotRateController.text.isEmpty ? "0" : slotRateController.text);
                              Navigator.of(context).pop(mAddFacilitySlotModel);
                              if (!_isSameRatesForSlots) {
                                slotRateController.clear();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // Add training address
  Widget _buildAddTrainingAddressBottomSheet(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: StatefulBuilder(builder: (BuildContext context, StateSetter newState) {
        return Wrap(children: [
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Add Training Address", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20, color: OQDOThemeData.blackColor)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: TextField(
                      controller: _buildingName,
                      autofocus: false,
                      maxLines: 1,
                      maxLength: 50,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorsUtils.greyButton,
                        hintText: 'Address Title',
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: TextField(
                      autofocus: false,
                      minLines: 4,
                      maxLines: 8,
                      controller: _address1,
                      maxLength: 50,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorsUtils.greyButton,
                        hintText: 'Enter Address 1',
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: TextField(
                      autofocus: false,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 50,
                      controller: _address2,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorsUtils.greyButton,
                        hintText: 'Enter Address 2',
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: TextField(
                      autofocus: false,
                      minLines: 1,
                      controller: _pincode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        counterText: '',
                        fillColor: ColorsUtils.greyButton,
                        hintText: 'Postal Code',
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: SimpleButton(
                      text: "Submit",
                      textcolor: Theme.of(context).colorScheme.onBackground,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 60,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        if (_buildingName.text.toString().trim().isEmpty) {
                          showSnackBar('Please enter building name', context);
                        } else if (_address1.text.toString().trim().isEmpty) {
                          showSnackBar('Please address line 1', context);
                        } else if (_address2.text.toString().trim().isEmpty) {
                          showSnackBar('Please address line 2', context);
                        } else if (_pincode.text.toString().trim().length < 6) {
                          showSnackBar('Invalid postal code', context);
                        } else {
                          Map addressMap = {};
                          addressMap['CoachId'] = OQDOApplication.instance.coachID;
                          addressMap['SubActivityId'] = selectedSubActivityID;
                          addressMap['AddressName'] = _buildingName.text.toString().trim();
                          addressMap['Address1'] = _address1.text.toString().trim();
                          addressMap['Address2'] = _address2.text.toString().trim();
                          addressMap['CityId'] = cityID;
                          addressMap['PinCode'] = _pincode.text.toString().trim();
                          debugPrint(json.encode(addressMap));
                          Navigator.of(context).pop(addressMap);
                        }
                      },
                    ),
                  )
                ],
              ))
        ]);
      }),
    );
  }

  void getSubActivity() {
    choosedinterest = activityListModel[0].Name;
    selectedActivityID = activityListModel[0].ActivityId.toString();
    subActivity = activityListModel.where((element) => element.Name == choosedinterest).toList();
    debugPrint(subActivity.toString());
  }

  void getActivityID() {
    List<ActivityBean> activityList = activityListModel.where((element) => element.Name == choosedinterest).toList();
    debugPrint(activityList.toString());
    selectedActivityID = activityList[0].ActivityId.toString();
  }

  void getSubActivityID() {
    List<SubActivitiesBean> selectedSubActivity = subActivity[0].SubActivities!.where((element) => element.Name == choosediActivity).toList();

    selectedSubActivityID = selectedSubActivity[0].SubActivityId.toString();
    debugPrint(selectedSubActivityID);
  }

  Future<void> getAllActivity() async {
    try {
      await _progressDialog.show();
      GetAllActivityAndSubActivityResponse getAllActivityAndSubActivityResponse =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachActivity(OQDOApplication.instance.coachID!);
      await _progressDialog.hide();
      if (getAllActivityAndSubActivityResponse.Data!.isNotEmpty) {
        setState(() {
          activityListModel = getAllActivityAndSubActivityResponse.Data!;
        });
        getSubActivity();
        getCoachTrainingCenterAddress();
      }
    } on CommonException catch (error) {
      _progressDialog.hide();
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void setSlotValue() async {
    var time = await showDurationPicker(
      context: context,
      initialTime: Duration(
          hours: int.parse("${hourfirst.text.isEmpty ? "0" : hourfirst.text}${hoursecond.text.isEmpty ? "0" : hoursecond.text}"),
          minutes: int.parse("${minutefirst.text.isEmpty ? "0" : minutefirst.text}${minutesecond.text.isEmpty ? "0" : minutesecond.text}")),
    );
    if (time != null) {
      if (time.inMinutes < 60) {
        showSnackBar('Slot time can not less than 60 minutes', context);
      } else if (time.inMinutes > 720) {
        showSnackBar('Slot time must be less than 12 hours', context);
      } else {
        if (addFacilitySlotList!.isNotEmpty) {
          showModalBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              backgroundColor: OQDOThemeData.whiteColor,
              builder: (BuildContext context) => const ShowClearSlotsBottomSheet()).then((value) {
            if (value != null) {
              bool data = value as bool;
              if (data) {
                setState(() {
                  addFacilitySlotList!.clear();
                  isSlotTimeChangeRequestAccepted = true;
                  if (time.inMinutes > 720) {
                    showSnackBar('Slot time must be less than 12 hours', context);
                  } else {
                    _slotTimeInMins = time.inMinutes;
                    String finalTime = formatDuration(time);
                    debugPrint(finalTime);
                    String hrs = finalTime.split(":")[0];
                    String mins = finalTime.split(":")[1];
                    String convertedHour = hrs.padLeft(2, '0');
                    String convertedMinute = mins.padLeft(2, '0');

                    setState(() {
                      hourfirst.text = convertedHour[0];
                      hoursecond.text = convertedHour[1];
                      minutefirst.text = convertedMinute[0];
                      minutesecond.text = convertedMinute[1];
                    });
                  }
                });
              }
            }
          });
        } else {
          if (time.inMinutes > 720) {
            showSnackBar('Slot time must be less than 12 hours', context);
          } else {
            _slotTimeInMins = time.inMinutes;
            String finalTime = formatDuration(time);
            debugPrint(finalTime);
            String hrs = finalTime.split(":")[0];
            String mins = finalTime.split(":")[1];
            String convertedHour = hrs.padLeft(2, '0');
            String convertedMinute = mins.padLeft(2, '0');

            setState(() {
              hourfirst.text = convertedHour[0];
              hoursecond.text = convertedHour[1];
              minutefirst.text = convertedMinute[0];
              minutesecond.text = convertedMinute[1];
            });
          }
        }
      }
    }
  }

  Widget showPicker(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).copyWith().size.height * 0.15,
      color: OQDOThemeData.whiteColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton(
              child: CustomTextView(
                label: 'Cancel',
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.blackColor),
              ),
              onPressed: () {
                slotTime = 0;
                Navigator.of(context).pop();
              }),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: 0,
              ),
              itemExtent: 32.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (int index) {
                slotTime = index;
              },
              children: [
                for (var value in slotListData)
                  CustomTextView(
                    label: '$value slot',
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w400),
                  ),
              ],
            ),
          ),
          CupertinoButton(
              child: CustomTextView(
                label: 'Ok',
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.blackColor),
              ),
              onPressed: () {
                var passingSlot = slotTime! + 1;
                slotTime = 0;
                Navigator.of(context).pop(passingSlot);
                debugPrint(passingSlot.toString());
              }),
        ],
      ),
    );
  }

  Future<void> getCoachTrainingCenterAddress() async {
    try {
      // await _progressDialog.show();
      var coachTrainingAddress =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachTrainingAddress(OQDOApplication.instance.coachID!);
      debugPrint("Coach training address -> $coachTrainingAddress");
      // await _progressDialog.hide();
      setState(() {
        coachTrainingAddressList = coachTrainingAddress;
      });
    } on CommonException catch (errorResponse) {
      debugPrint(errorResponse.toString());
      // await _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    } on NoConnectivityException catch (_) {
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      debugPrint(error.toString());
      // await _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void validate() {
    if (bookingType == 'I') {
      if (!_isTrainingAddress && !_isTraineeAddress) {
        showSnackBar('Please select any of address type', context);
      } else if (_isTrainingAddress && selectedAddressId.isEmpty) {
        showSnackBar('Please select training address', context);
      } else {
        addBatchsetupCall();
        // showModalBottomSheet(
        //     context: context,
        //     isDismissible: false,
        //     enableDrag: false,
        //     shape: const RoundedRectangleBorder(
        //       borderRadius: BorderRadius.vertical(
        //         top: Radius.circular(20),
        //       ),
        //     ),
        //     clipBehavior: Clip.antiAliasWithSaveLayer,
        //     backgroundColor: OQDOThemeData.whiteColor,
        //     builder: (context) => const Show24HrsAlearBottomSheet()).then((value) {
        //   if (value != null) {
        //     bool data = value as bool;
        //     if (data) {
        //       addBatchsetupCall();
        //     }
        //   }
        // });
      }
    } else {
      if (!_isTrainingAddress && !_isTraineeAddress) {
        showSnackBar('Please select any of address type', context);
      } else {
        addBatchsetupCall();
        // showModalBottomSheet(
        //     context: context,
        //     isDismissible: false,
        //     enableDrag: false,
        //     shape: const RoundedRectangleBorder(
        //       borderRadius: BorderRadius.vertical(
        //         top: Radius.circular(20),
        //       ),
        //     ),
        //     clipBehavior: Clip.antiAliasWithSaveLayer,
        //     backgroundColor: OQDOThemeData.whiteColor,
        //     builder: (context) => const Show24HrsAlearBottomSheet()).then((value) {
        //   if (value != null) {
        //     bool data = value as bool;
        //     if (data) {
        //       addBatchsetupCall();
        //     }
        //   }
        // });
      }
    }
    // if (_slotTimeInMins < 60) {
    //   Fluttertoast.showToast(msg: "60 mins default slot", toastLength: Toast.LENGTH_SHORT);
    // } else if (selectedSubActivityID!.isEmpty) {
    //   Fluttertoast.showToast(msg: "Please select activity & sub-activity.", toastLength: Toast.LENGTH_SHORT);
    // } else if (_isTrainingAddress && selectedAddressId!.isEmpty) {
    //   Fluttertoast.showToast(msg: "Please select training address", toastLength: Toast.LENGTH_SHORT);
    // } else if (addFacilitySlotList!.isEmpty) {
    //   Fluttertoast.showToast(msg: "Please Add Slots", toastLength: Toast.LENGTH_SHORT, fontSize: 16.0);
    // } else {
    //   addBatchsetupCall();
    // }
  }

  Future<void> addCoachTrainingAddress(Map addressMap) async {
    try {
      await _progressDialog.show();
      var response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).addCoachTrainingAddress(addressMap, false);
      debugPrint(response);
      await _progressDialog.hide();
      getCoachTrainingCenterAddress();
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
    }
  }

  void addBatchsetupCall() {
    Map addBatchSlotMap = {};
    addBatchSlotMap['CoachBatchSetupId'] = '';
    addBatchSlotMap['CoachId'] = OQDOApplication.instance.coachID;
    addBatchSlotMap['SubActivityId'] = selectedSubActivityID;

    Map coachSetupInnerMap = {};
    coachSetupInnerMap['CoachBatchSetupDetailId'] = '';
    coachSetupInnerMap['CoachBatchSetupId'] = '';
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now);
    coachSetupInnerMap['EffectiveDate'] = formattedDate;
    coachSetupInnerMap['BookingType'] = bookingType;
    coachSetupInnerMap['Name'] = nameController.text.toString().trim();
    coachSetupInnerMap['SlotTimeMinute'] = _slotTimeInMins;
    coachSetupInnerMap['RatePerHour'] = _isSameRatesForSlots ? priceController.text.toString().trim() : null;
    coachSetupInnerMap['BatchCapacity'] = person.text.toString().trim();
    coachSetupInnerMap['IsTrainingAddress'] = _isTrainingAddress;
    coachSetupInnerMap['IsSameSlotRate'] = _isSameRatesForSlots;
    coachSetupInnerMap['MinimumSlot'] = selectedMinimumSlot;
    coachSetupInnerMap['MaxGroupSize'] = int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim()) == 0
        ? null
        : int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim());

    Map trainingAddressMap = {};
    trainingAddressMap['AddressId'] = selectedAddressId;
    // List<Map> list = [];
    // if (_isTrainingAddress) {
    //   for (int i = 0; i < coachTrainingAddressList!.length; i++) {
    //     if (coachTrainingAddressList![i].isSelected != null) {
    //       if (coachTrainingAddressList![i].isSelected!) {
    //         trainingAddressMap['AddressId'] = coachTrainingAddressList![i].coachTrainingAddressId!;
    //         list.add(trainingAddressMap);
    //       }
    //     }
    //   }
    // }

    if (_isTrainingAddress) {
      coachSetupInnerMap['coachBatchSetupAddressDtos'] = [trainingAddressMap];
    }
    coachSetupInnerMap['IsTraineeAddress'] = _isTraineeAddress;
    coachSetupInnerMap['IsActive'] = true;

    List<Map> slotList = [];
    for (int i = 0; i < addFacilitySlotList!.length; i++) {
      for (int j = 0; j < addFacilitySlotList![i].slotsModelList!.length; j++) {
        Map slotMap = {};
        SlotsModel slotsModel = addFacilitySlotList![i].slotsModelList![j];
        slotMap['DayNos'] = addFacilitySlotList![i].selectedSlotsDayList;
        slotMap['StartTimeInMinute'] = slotsModel.startTimeInMinutes;
        slotMap['NoOfSlot'] = slotsModel.slots;
        slotMap['EndTimeInMinute'] = slotsModel.endTimeInMinutes;
        slotMap['RatePerHour'] = addFacilitySlotList![i].ratePerHour;
        slotList.add(slotMap);
      }
    }
    coachSetupInnerMap['coachBatchSetupDaySlotDtos'] = slotList;
    addBatchSlotMap['CoachBatchSetupDetailDtos'] = [coachSetupInnerMap];
    debugPrint(json.encode(addBatchSlotMap));
    callBatchSetup(addBatchSlotMap);
  }

  Future<void> callBatchSetup(Map addBatchSlotMap) async {
    try {
      await _progressDialog.show();
      var response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).addCoach(addBatchSlotMap);
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Batch added successfully', context, false);
        Navigator.of(context).pop(response);
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
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
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void getAddressFromSelectedAddress() {
    List<CoachTrainingAddress> getSelectedAddressList = coachTrainingAddressList!.where((element) => element.addressName == choosedAddress).toList();
    selectedAddressId = getSelectedAddressList[0].coachTrainingAddressId.toString();
  }

  void setFullAddressFromSelectedAddress() {
    List<CoachTrainingAddress> getSelectedAddressList = coachTrainingAddressList!.where((element) => element.addressName == choosedAddress).toList();
    selectedAddressFullName =
        '${getSelectedAddressList[0].addressName},${getSelectedAddressList[0].address1},${getSelectedAddressList[0].address2},${getSelectedAddressList[0].cityName}-${getSelectedAddressList[0].pinCode}';
  }

  _onChangeSlotRatesPerHour(String val) {
    slotRateController.text = val;
    if (val.isNotEmpty && _isSameRatesForSlots && addFacilitySlotList != null && addFacilitySlotList!.isNotEmpty) {
      for (var slot in addFacilitySlotList!) {
        slot.ratePerHour = double.parse(slotRateController.text.isEmpty ? "0" : slotRateController.text);
      }
      setState(() {});
    }
  }
}
