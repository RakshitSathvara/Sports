// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/add_facility_slot_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/Show24HrsAleartBottomSheet.dart';
import 'package:oqdo_mobile_app/screens/setup/setups_bottom_sheets/ShowClearSlotsBottomSheet.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../model/upload_file_response.dart';
import '../../viewmodels/service_provider_setup_viewmodel.dart';

class AddFacilityPage extends StatefulWidget {
  const AddFacilityPage({Key? key}) : super(key: key);

  @override
  AddFacilityPageState createState() => AddFacilityPageState();
}

class AddFacilityPageState extends State<AddFacilityPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  final formKey = GlobalKey<FormState>();

  // Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController titleController = TextEditingController();
  TextEditingController subTitleController = TextEditingController();
  TextEditingController aboutyourself = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController person = TextEditingController();
  TextEditingController hourfirst = TextEditingController();
  TextEditingController hoursecond = TextEditingController();
  TextEditingController minutefirst = TextEditingController();
  TextEditingController minutesecond = TextEditingController();
  final slotRateController = TextEditingController();
  final groupSizeController = TextEditingController();
  AddFacilitySlotModel mAddFacilitySlotModel = AddFacilitySlotModel();
  bool _monday = false;
  bool _tuesday = false;
  bool _wednesday = false;
  bool _thurday = false;
  bool _friday = false;
  bool _saturday = false;
  bool _sunday = false;
  String? choosedinterest;
  String? choosediActivity;
  late String bookingType;
  final picker = ImagePicker();
  File? listingImage;
  List<XFile>? imagesList = [];
  late ProgressDialog _progressDialog;
  List<ActivityBean> activityListModel = [];
  List<ActivityBean> subActivityModelList = [];
  List<ActivityBean> subActivity = [];
  String? selectedSubActivityID = '';
  String? selectedActivityID = '';
  final Duration _defaultSlotDuration = const Duration(hours: 00, minutes: 60);
  int _slotTimeInMins = 60;
  List<AddFacilitySlotModel>? addFacilitySlotList = [];
  int? listingImgId = 0;
  List<int>? facilityImgIds = [];
  List<int> slotListData = [];
  int? slotTime = 0;
  int? finalSlotTime = 0;
  bool _isSameRatesForSlots = true;
  bool isSlotTimeChangeRequestAccepted = true;

  @override
  void initState() {
    super.initState();
    bookingType = "I";
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      getAllActivity();
      setSlotInintTime();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Add Facility Setup',
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
              } else if (titleController.text.toString().trim().isEmpty) {
                showSnackBar('Title required', context);
              } else if (subTitleController.text.toString().trim().isEmpty) {
                showSnackBar('Sub-Title required', context);
              } else if (facilityImgIds!.isEmpty) {
                showSnackBar('Please add at least One Facility Image', context);
              } else if (listingImgId == 0) {
                showSnackBar('Please Add Listing Image', context);
              } else if (aboutyourself.text.toString().trim().isEmpty) {
                showSnackBar('Description required', context);
              } else if (_slotTimeInMins < 60) {
                showSnackBar('Slot time can not less than 60 minutes', context);
              } else if (_slotTimeInMins > 1439) {
                showSnackBar('Slot time must be less than 12 hours', context);
              } else if (_isSameRatesForSlots && price.text.toString().trim().isEmpty) {
                showSnackBar('Rate required', context);
              } else if (_isSameRatesForSlots && price.text.toString().trim().isNotEmpty && (double.parse(price.text) < 1)) {
                showSnackBar(
                  'Rate/hour should be greater than or equals to 1',
                  context,
                );
              } else if (person.text.toString().trim().isEmpty) {
                showSnackBar('Facility Capacity required', context);
              } else if (person.text.toString().trim().isNotEmpty && (double.parse(person.text) < 1)) {
                showSnackBar('Facility Capacity must be greater than 0', context);
              } else if (bookingType == 'G' && groupSizeController.text.trim().isEmpty) {
                showSnackBar('Max group size required', context);
              } else if (bookingType == 'G' && int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim()) == 0) {
                showSnackBar('Max group size must be greater than zero', context);
              } else if (addFacilitySlotList!.isEmpty) {
                showSnackBar('Please add slot', context);
              } else {
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
                    builder: (context) => const Show24HrsAlearBottomSheet()).then((value) {
                  if (value != null) {
                    bool data = value as bool;
                    if (data) {
                      setupApiCall();
                    }
                  }
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 10),
              child: CustomTextView(
                label: 'Submit',
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                        label: "Activity",
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
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
                            value: choosedinterest,
                            items: activityListModel.map((interest) {
                              return DropdownMenuItem(
                                value: interest.Name,
                                child: CustomTextView(label: interest.Name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                choosedinterest = value;
                                debugPrint(choosedinterest);
                                getActivityID();
                                getSubActivity();
                              });
                            }),
                      ),
                    ),
                    subActivity.isNotEmpty
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
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
                                          choosediActivity = value;
                                        });
                                        getSubActivityID();
                                      }),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextFormField(
                      controller: titleController,
                      read: false,
                      obscureText: false,
                      labelText: 'Title',
                      maxlength: 50,
                      maxlines: 1,
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextFormField(
                      controller: subTitleController,
                      read: false,
                      // key: formKey,
                      obscureText: false,
                      maxlength: 50,
                      maxlines: 1,

                      labelText: 'Sub Title',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Upload Image(s)',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF818181)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              if (imagesList!.length > 2) {
                                showSnackBar('Maximum 3 images allowed', context);
                              } else {
                                getMultiplePicFromGallery();
                              }
                            },
                            child: const CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage("assets/images/camera.png"),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: imagesList!.isNotEmpty,
                              child: GestureDetector(
                                  onTap: () {
                                    facilityImgIds!.clear();
                                    imagesList!.clear();
                                    setState(() {});
                                  },
                                  child: CustomTextView(label: 'Clear')),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 70,
                                  child: PageView.builder(
                                      controller: controller,
                                      itemBuilder: (context, index) {
                                        return Card(
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: imagesList!.isNotEmpty
                                                ? Image.file(
                                                    File(imagesList![index].path),
                                                    fit: BoxFit.contain,
                                                  )
                                                : const SizedBox());
                                      },
                                      itemCount: imagesList!.length),
                                ),
                                Visibility(
                                  visible: imagesList!.length > 1,
                                  child: SmoothPageIndicator(
                                    controller: controller,
                                    count: imagesList!.length,
                                    effect: SlideEffect(
                                        dotHeight: 12, dotWidth: 12, dotColor: ColorsUtils.greyButton, activeDotColor: Theme.of(context).colorScheme.primary
                                        // strokeWidth: 5,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Listing Image',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xFF818181)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              bottomSheetImage();
                            },
                            child: const CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage("assets/images/camera.png"),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: listingImage != null,
                          child: SizedBox(
                            width: 110,
                            height: 70,
                            child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: listingImage != null
                                    ? Image.file(
                                        listingImage!,
                                        fit: BoxFit.contain,
                                      )
                                    : const SizedBox()),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextFormField(
                      controller: aboutyourself,
                      read: false,
                      obscureText: false,
                      labelText: 'Description',
                      hintText: 'If there\'s Change in Facility Address',
                      validator: Validator.notEmpty,
                      maxlength: 250,
                      // inputformat: [
                      //   FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 _]+')),
                      // ],
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                    ),
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
                                  person.text = "";
                                  groupSizeController.clear();
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
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: CustomTextView(
                        label: "Slot Time",
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: TextField(
                                readOnly: !isSlotTimeChangeRequestAccepted,
                                autofocus: false,
                                controller: hourfirst,
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
                            const SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                readOnly: !isSlotTimeChangeRequestAccepted,
                                autofocus: false,
                                controller: hoursecond,
                                textAlign: TextAlign.center,
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
                            const SizedBox(
                              width: 8,
                            ),
                            CustomTextView(
                              label: ":",
                              type: styleSubTitle,
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                readOnly: !isSlotTimeChangeRequestAccepted,
                                autofocus: false,
                                controller: minutefirst,
                                textAlign: TextAlign.center,
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
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-5]')), FilteringTextInputFormatter.digitsOnly],
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
                            const SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                readOnly: !isSlotTimeChangeRequestAccepted,
                                autofocus: false,
                                controller: minutesecond,
                                textAlign: TextAlign.center,
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
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            var time = await showDurationPicker(
                                context: context,
                                initialTime: Duration(
                                    hours: int.parse("${hourfirst.text.isEmpty ? "0" : hourfirst.text}${hoursecond.text.isEmpty ? "0" : hoursecond.text}"),
                                    minutes: int.parse(
                                        "${minutefirst.text.isEmpty ? "0" : minutefirst.text}${minutesecond.text.isEmpty ? "0" : minutesecond.text}")),
                                baseUnit: BaseUnit.minute);
                            if (time!.inMinutes < 60) {
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
                                        finalSlotTime = 0;
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
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: Image.asset(
                              "assets/images/pick_time.png",
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
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
                                          price.clear();
                                          slotRateController.clear();
                                          addFacilitySlotList?.clear();
                                          isSlotTimeChangeRequestAccepted = true;
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
                                price.clear();
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
                      height: 24,
                    ),
                    CustomTextFormField(
                      controller: price,
                      read: !_isSameRatesForSlots,
                      enabled: _isSameRatesForSlots,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      maxlines: 1,
                      maxlength: 6,
                      obscureText: false,
                      labelText: 'Rate/hour (S\$)',
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return "Required field";
                        } else if (double.parse(value) < 1) {
                          return "Rate/hour should be greater than or equals to 1";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onchanged: (value) {
                        debugPrint("===>>>$value<<<===");
                        _onChangeSlotRatesPerHour(value);
                        return "";
                      },
                    ),
                    bookingType != 'G'
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextFormField(
                                controller: person,
                                read: bookingType == 'G' ? true : false,
                                obscureText: false,
                                inputformat: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                                maxlines: 1,
                                maxlength: 3,
                                labelText: 'Facility Capacity (Person)',
                                validator: Validator.notEmpty,
                                keyboardType: const TextInputType.numberWithOptions(signed: true),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 20,
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
                                return "Value must be greater than zero";
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
                                    hours: int.parse("${hourfirst.text.isEmpty ? "0" : hourfirst.text}${hoursecond.text.isEmpty ? "0" : hoursecond.text}"),
                                    minutes:
                                        int.parse("${minutefirst.text.isEmpty ? "0" : minutefirst.text}${minutesecond.text.isEmpty ? "0" : minutesecond.text}"))
                                .inMinutes;
                            if (_isSameRatesForSlots && price.text.isEmpty) {
                              showSnackBar('Rate required', context);
                            } else if (_isSameRatesForSlots && double.parse(price.text) < 1) {
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
                                  enableDrag: false,
                                  // isScrollControlled: true,
                                  builder: (BuildContext ctx) {
                                    return _buildAddFacilityBottomSheet(ctx);
                                  }).then((value) => {
                                    if (value != null)
                                      {
                                        setState(() {
                                          // addSlotList.add(value);
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
                  ],
                ),
              ),
            ),
          ),
        ),
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
                padding: const EdgeInsets.fromLTRB(22.0, 8, 18, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const SizedBox(width: 10),
                    CustomTextView(
                      label: "Start Time",
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: CustomTextView(
                        label: "End Time",
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 48,
                    ),
                    // Expanded(
                    //   child: CustomTextView(
                    //     label: "S\$ ${addFacilitySlotModel.ratePerHour?.toStringAsFixed(2) ?? 0}/hour",
                    //     textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //           color: Theme.of(context).colorScheme.onSurface,
                    //           fontSize: 14,
                    //         ),
                    //     textOverFlow: TextOverflow.ellipsis,
                    //     maxLine: 4,
                    //   ),
                    // ),
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
    // debugPrint('Length >>> ' + slotList.slotList![index].totalSlot.toString());
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
                  width: 52,
                ),
                SizedBox(
                  height: 15,
                  child: ImageIcon(
                    const AssetImage("assets/images/arrow_right.png"),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(
                  width: 52,
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

  // Image pick
  bottomSheetImage() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Photo Library',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      if (Constants.androidVersion >= 13) {
                        getPicFromGallery();
                      } else {
                        // final serviceStatus = await Permission.storage.isGranted;
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          getPicFromGallery();
                        } else if (status == PermissionStatus.denied) {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          await openAppSettings();
                        }
                      }
                    }),
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Camera',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      var status = await Permission.camera.request();
                      if (status == PermissionStatus.granted) {
                        getPicFromCam();
                      } else if (status == PermissionStatus.denied) {
                        if (status == PermissionStatus.granted) {
                          getPicFromCam();
                        } else {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        }
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        await openAppSettings();
                      }
                    } //getPicFromCam
                    ),
              ],
            ),
          );
        });
  }

  Future getPicFromCam() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        listingImage = File(pickedFile.path);
        setState(() {});
        var bytes = File(listingImage!.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        uploadFile(convertedBytes);
      } else {
        await _progressDialog.hide();
        setState(() {});
        // showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getPicFromGallery() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        listingImage = File(pickedFile.path);
        setState(() {});
        var bytes = File(listingImage!.path).readAsBytesSync();
        String convertedBytes = base64Encode(bytes);
        uploadFile(convertedBytes);
      } else {
        await _progressDialog.hide();
        setState(() {});
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getMultiplePicFromGallery() async {
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickMultiImage(imageQuality: 60);

    if (pickedFile.length > 3) {
      await _progressDialog.hide();
      setState(() {});
      showSnackBar('Maximum 3 images allowed', context);
      return;
    } else {
      int count = imagesList!.length;
      debugPrint('Previous count -> + $count');
      debugPrint('Picked count -> + ${pickedFile.length}');
      count = count + pickedFile.length;
      if (count > 3) {
        await _progressDialog.hide();
        setState(() {});
        showSnackBar('Maximum 3 images allowed', context);
        return;
      } else {
        double maxMb = 0.00;
        for (int i = 0; i < pickedFile.length; i++) {
          var byte = await File(pickedFile[i].path).length();
          var kb = byte / 1024;
          var mb = kb / 1024;
          debugPrint("File size -> ${mb.toString()}");
          if (mb > 10.0) {
            await _progressDialog.hide();
            maxMb = 0.0;
            setState(() {});
            showSnackBarErrorColor("Please select image below 10 MB", context, true);
            return;
          } else {
            maxMb = maxMb + mb;
          }
        }
        await _progressDialog.hide();
        setState(() {});
        if (maxMb < 30) {
          imagesList!.addAll(pickedFile);
          uploadFacilityImgFiles(pickedFile);
        } else {
          showSnackBarErrorColor("Please select image below 30 MB", context, true);
        }
      }
    }
  }

  // Add facility bottom sheet
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
    // _thursday = false;
    // _friday = false;
    // _saturday = false;
    // _sunday = false;
    return SafeArea(
      child: StatefulBuilder(builder: (innerContext, setState) {
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
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(
                        width: 120,
                      ),
                      CustomTextView(
                        label: "End Time",
                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                      ),
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
                                          var currentSelectedTime = mDateFormat.parse("$convertedHour:$convertedMinute");
                                          var previousEndTime = mDateFormat.parse(mAddFacilitySlotModel.slotsModelList![position - 1].endTime!);
                                          debugPrint(previousEndTime.toString());
                                          if (currentSelectedTime.isBefore(previousEndTime)) {
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
                                                    finalSlotTime = mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes!;
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
                                                  finalSlotTime = mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes!;
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
                                                    finalSlotTime = mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes!;
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
                                                    finalSlotTime = mAddFacilitySlotModel.slotsModelList![position].endTimeInMinutes!;
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
                      debugPrint('add new time -> $finalSlotTime');
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
                              showSnackBar('Please select days', innerContext);
                            } else if (!_isSameRatesForSlots && slotRateController.text.isEmpty) {
                              showSnackBar('Rate required', innerContext);
                            } else if (!_isSameRatesForSlots && double.parse(slotRateController.text) < 1) {
                              showSnackBar('Rate/hour should be greater than or equals to 1', context);
                            } else if (mAddFacilitySlotModel.slotsModelList!.isEmpty) {
                              showSnackBar('Please add slot', innerContext);
                            } else if (slotModelSlotData.isNotEmpty) {
                              showSnackBar('Please select slot', innerContext);
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

  Future<void> getAllActivity() async {
    try {
      await _progressDialog.show();
      GetAllActivityAndSubActivityResponse getAllActivityAndSubActivityResponse =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getAllActivity();

      if (getAllActivityAndSubActivityResponse.Data!.isNotEmpty) {
        _progressDialog.hide();
        setState(() {
          activityListModel = getAllActivityAndSubActivityResponse.Data!;
        });
      }
    } on CommonException catch (error) {
      _progressDialog.hide();
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
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void getActivityID() {
    List<ActivityBean> activityList = activityListModel.where((element) => element.Name == choosedinterest).toList();
    debugPrint(activityList.toString());
    selectedActivityID = activityList[0].ActivityId.toString();
  }

  void getSubActivity() {
    subActivity.clear();
    choosediActivity = null;
    subActivity = activityListModel.where((element) => element.Name == choosedinterest).toList();
    debugPrint(subActivity.toString());
  }

  void getSubActivityID() {
    List<SubActivitiesBean> selectedSubActivity = subActivity[0].SubActivities!.where((element) => element.Name == choosediActivity).toList();

    selectedSubActivityID = selectedSubActivity[0].SubActivityId.toString();
    debugPrint(selectedSubActivityID);
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  String intToTimeLeft(int value) {
    int h, m;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    String hourLeft = h.toString().length < 2 ? "0$h" : h.toString();
    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();
    String result = "$hourLeft:$minuteLeft";
    return result;
  }

  TimeOfDay minutesToTimeOfDay(int minutes) {
    Duration duration = Duration(minutes: minutes);
    List<String> parts = duration.toString().split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> uploadFile(String base64File) async {
    await _progressDialog.show();
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = listingImage!.path.split('/').last;
    uploadFileRequest['FileExtension'] = listingImage!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = base64File;
    try {
      UploadFileResponse uploadFileResponse = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).uploadFile(uploadFileRequest);
      await _progressDialog.hide();
      debugPrint('Listing Upload File Response -> ${uploadFileResponse.FileStorageId}');
      listingImgId = uploadFileResponse.FileStorageId;
    } on CommonException catch (error) {
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
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> uploadFacilityImgFiles(List<XFile> pickedFile) async {
    for (int i = 0; i < pickedFile.length; i++) {
      await _progressDialog.show();
      Map uploadFileRequest = {};
      uploadFileRequest['FileStorageId'] = null;
      uploadFileRequest['FileName'] = pickedFile[i].path.split('/').last;
      uploadFileRequest['FileExtension'] = pickedFile[i].path.split('/').last.split('.')[1];
      var bytes = File(pickedFile[i].path).readAsBytesSync();
      String convertedBytes = base64Encode(bytes);
      uploadFileRequest['FilePath'] = convertedBytes;
      try {
        UploadFileResponse uploadFileResponse = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).uploadFile(uploadFileRequest);
        await _progressDialog.hide();
        debugPrint('Upload File Response -> ${uploadFileResponse.FileStorageId}');
        facilityImgIds!.add(uploadFileResponse.FileStorageId!);
      } on CommonException catch (error) {
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
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
        debugPrint(error.message);
      } on NoConnectivityException catch (_) {
        await _progressDialog.hide();
        showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
      } catch (error) {
        await _progressDialog.hide();
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    }
  }

  void setupApiCall() {
    Map addFacility = {};
    List<Map> slotList = [];
    for (int i = 0; i < addFacilitySlotList!.length; i++) {
      for (int j = 0; j < addFacilitySlotList![i].slotsModelList!.length; j++) {
        Map slotMap = {};
        SlotsModel slotsModel = addFacilitySlotList![i].slotsModelList![j];
        slotMap['DayNos'] = addFacilitySlotList![i].selectedSlotsDayList;
        slotMap['StartTimeInMinute'] = slotsModel.startTimeInMinutes;
        slotMap['NoOfSlot'] = slotsModel.slots;
        slotMap['EndTimeInMinute'] = slotsModel.endTimeInMinutes;
        slotMap['RatePerHour'] = addFacilitySlotList![i].ratePerHour ?? 0;
        slotList.add(slotMap);
      }
    }
    List<Map> facilityImagesList = [];
    for (int i = 0; i < facilityImgIds!.length; i++) {
      Map map = {};
      map['FileStorageId'] = facilityImgIds![i];
      map['FileName'] = '';
      map['FilePath'] = '';
      map['FileExtension'] = '';
      map['FileBase64'] = '';
      facilityImagesList.add(map);
    }
    addFacility['FacilitySetupId'] = 0;
    addFacility['FacilityProviderId'] = OQDOApplication.instance.facilityID;
    addFacility['Title'] = titleController.text.toString().trim();
    addFacility['SubTitle'] = subTitleController.text.toString().trim();
    addFacility['Description'] = aboutyourself.text.toString().trim();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now);
    debugPrint(formattedDate);
    addFacility['EffectiveDate'] = formattedDate;
    addFacility['ListingPageImageId'] = listingImgId!;
    addFacility['SubactivityId'] = selectedSubActivityID;
    addFacility['BookingType'] = bookingType;
    addFacility['SlotTimeMinute'] = _slotTimeInMins;
    addFacility['RatePerHour'] = _isSameRatesForSlots ? double.parse(price.text.trim().isEmpty ? "0" : price.text.trim()) : null;
    addFacility['FacilityCapacity'] = person.text.toString().trim();
    addFacility["FacilitySetupDaySlotDtos"] = slotList;
    addFacility["FacilityImages"] = facilityImagesList;
    addFacility["FacilitySetupPrvReviewDtos"] = [];
    addFacility['IsSameSlotRate'] = _isSameRatesForSlots;
    addFacility['MaxGroupSize'] = int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim()) == 0
        ? null
        : int.parse(groupSizeController.text.trim().isEmpty ? "0" : groupSizeController.text.trim());
    debugPrint(json.encode(addFacility));
    callAddFacilitySetup(addFacility);
  }

  Future<void> callAddFacilitySetup(Map addFacility) async {
    try {
      await _progressDialog.show();
      String response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).addFacilitySetupCall(addFacility);
      debugPrint('callAddFacilitySetup -> $response');
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        showSnackBarColor('Setup added successfully', context, false);
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
      debugPrint(error.toString());
      await _progressDialog.hide();
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      // showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Widget showPicker(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).copyWith().size.height * 0.25,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextView(
                      label: '$value slot',
                      textStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16.0, color: OQDOThemeData.blackColor, fontWeight: FontWeight.w400),
                    ),
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

  String getEndTimeInVisibleFormat(int endTimeMinutes) {
    int hour = endTimeMinutes ~/ 60;
    int minutes = endTimeMinutes % 60;
    return '${hour.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}';
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
