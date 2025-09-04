// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../../helper/helpers.dart';
import '../../../model/common_passing_args.dart';
import '../../../model/location_selection_response_model.dart';
import '../../../model/upload_file_response.dart';
import '../../../oqdo_application.dart';
import '../../../utils/string_manager.dart';
import '../../../utils/validator.dart';
import '../../../viewmodels/end_user_resgistration_view_model.dart';

class FacilityAddPageOne extends StatefulWidget {
  final CommonPassingArgs commonPassingArgs;

  const FacilityAddPageOne(this.commonPassingArgs, {super.key});

  @override
  _FacilityAddPageOneState createState() => _FacilityAddPageOneState(commonPassingArgs);
}

class _FacilityAddPageOneState extends State<FacilityAddPageOne> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController facilityName = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController regNum = TextEditingController();

  List<TextEditingController> name = [];
  List<TextEditingController> mobile = [];
  int counter = 1;
  final picker = ImagePicker();
  List<File> selectedimage = [];
  // File? profilepic;
  CroppedFile? croppedFile;
  late Helper hp;

  final CommonPassingArgs _commonPassingArgs;
  late ProgressDialog _progressDialog;
  List<DataBean>? location = [];
  String? choosedlocation;
  int? selectedCityId;
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  List<ContactDetails> contactDetailsList = [];

  _FacilityAddPageOneState(this._commonPassingArgs);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedCityCountryCode = '';
  String? selectedCityID = '';
  String? mobileNoLengthStr = '';
  int? mobileNoLength = 0;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    name.add(TextEditingController());
    mobile.add(TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      // getAllCity();
      // facilityName.text = _commonPassingArgs.facilityName!;
      getShredPrefValues();
    });
  }

  void getShredPrefValues() async {
    choosedlocation = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);
    selectedCityCountryCode = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
    selectedCityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
    mobileNoLengthStr = OQDOApplication.instance.storage.getStringValue(AppStrings.mobileNoLength);
    mobileNoLength = int.parse(mobileNoLengthStr!);
    debugPrint(choosedlocation);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    //   _progressDialog.style(message: "Please wait..");
    // });
    final textColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 80,
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Center(
                      child: CustomTextView(
                        label: 'Facility',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                      ),
                    ),
                    Divider(
                      thickness: 3,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.78),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // CustomTextFormField(
                    //   controller: facilityName,
                    //   read: false,
                    //   obscureText: false,
                    //   maxlines: 1,
                    //   maxlength: 50,
                    //   inputformat: [
                    //     FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_ ]+')),
                    //   ],
                    //   fillColor: Theme.of(context).colorScheme.background,
                    //   labelText: 'Facility Name',
                    //   validator: Validator.notEmpty,
                    //   keyboardType: TextInputType.text,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Select City',
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 17.0),
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<dynamic>(
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.primary),
                            dropdownColor: Theme.of(context).colorScheme.onBackground,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(15),
                            hint: CustomTextView(
                              label: choosedlocation,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: textColor),
                            ),
                            value: choosedlocation,
                            items: location!.map((country) {
                              return DropdownMenuItem(
                                value: country.CountryName,
                                child: CustomTextView(
                                  label: country.CountryName!,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: textColor),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              debugPrint('Selected city : - $value');
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  choosedlocation = value;
                                });
                                checkForSelectedCity();
                              });
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Postal Code',
                        type: styleSubTitle,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 16.0),
                      ),
                    ),
                    PinCodeTextField(
                      pinBoxHeight: 55,
                      pinBoxWidth: width / 8.0,
                      pinBoxRadius: 5,
                      autofocus: false,
                      controller: postalcode,
                      hideCharacter: false,
                      highlight: true,
                      highlightColor: Theme.of(context).colorScheme.secondaryContainer,
                      defaultBorderColor: Theme.of(context).colorScheme.primary.withOpacity(0.53),
                      hasTextBorderColor: Theme.of(context).colorScheme.primary.withOpacity(0.53),
                      errorBorderColor: Theme.of(context).colorScheme.error,
                      maxLength: 6,
                      hasError: false,
                      maskCharacter: "*",
                      //😎
                      onTextChanged: (text) {},
                      onDone: (text) async {},
                      wrapAlignment: WrapAlignment.spaceEvenly,
                      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                      pinTextStyle: TextStyle(fontSize: 25.0, color: textColor),
                      pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                      pinBoxColor: Theme.of(context).colorScheme.secondaryContainer,
                      pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
                      //                    highlightAnimation: true,
                      //highlightPinBoxColor: Colors.red,
                      highlightAnimationBeginColor: Theme.of(context).colorScheme.onBackground,
                      highlightAnimationEndColor: Theme.of(context).colorScheme.background.withOpacity(0.12),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: address,
                      read: false,
                      obscureText: false,
                      maxlength: 200,
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelText: 'Address',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    CustomTextView(
                      label: 'Upload Profile Photo',
                      textStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17.0, color: textColor, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            bottomSheetImage();
                          },
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage("assets/images/camera.png"),
                          ),
                        ),
                        const SizedBox(
                          width: 40.0,
                        ),
                        croppedFile != null
                            ? SizedBox(
                                width: 110,
                                height: 70,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Image.file(
                                    File(croppedFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          width: 20.0,
                        ),
                        croppedFile != null
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    croppedFile = null;
                                    _commonPassingArgs.profileImageUploadId = "";
                                  });
                                },
                                child: CustomTextView(
                                  label: 'Clear',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: textColor, fontSize: 16.0, fontWeight: FontWeight.w600),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: CustomTextView(
                            label: 'Contact Person',
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 17.0),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            showModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                isScrollControlled: true,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0, bottom: 30.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomTextView(
                                                label: 'Contact Details',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 16.0),
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop(context);
                                                  },
                                                  child: const Icon(Icons.close, size: 30.0)),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 15.0,
                                          ),
                                          CustomTextFormField(
                                            controller: contactPersonController,
                                            read: false,
                                            obscureText: false,
                                            maxlines: 1,
                                            inputformat: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                                            ],
                                            maxlength: 50,
                                            labelText: 'Person Name',
                                            // keyboardType: TextInputType.text,
                                          ),
                                          const SizedBox(
                                            height: 30.0,
                                          ),
                                          mobileNoLength! > 0
                                              ? CustomTextFormField(
                                                  controller: mobileNumberController,
                                                  read: false,
                                                  obscureText: false,
                                                  maxlines: 1,
                                                  inputformat: [
                                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                    FilteringTextInputFormatter.digitsOnly,
                                                  ],
                                                  maxlength: mobileNoLength,
                                                  labelText: 'Mobile Number',
                                                  keyboardType: TextInputType.number,
                                                )
                                              : CustomTextFormField(
                                                  controller: mobileNumberController,
                                                  read: false,
                                                  obscureText: false,
                                                  maxlines: 1,
                                                  maxlength: 12,
                                                  inputformat: [
                                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                    FilteringTextInputFormatter.digitsOnly,
                                                  ],
                                                  labelText: 'Mobile Number',
                                                  keyboardType: TextInputType.number,
                                                ),
                                          const SizedBox(
                                            height: 30.0,
                                          ),
                                          MyButton(
                                            text: "Submit",
                                            textcolor: textColor,
                                            textsize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterspacing: 0.7,
                                            buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                                            buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                                            buttonheight: 60,
                                            buttonwidth: width,
                                            radius: 15,
                                            onTap: () async {
                                              if (contactPersonController.text.toString().trim().isEmpty) {
                                                showSnackBar('Person name required', context);
                                              } else if (mobileNumberController.text.trim().isEmpty) {
                                                showSnackBar('Mobile number required', context);
                                              } else if (mobileNumberController.text.toString().trim().length < mobileNoLength!) {
                                                showSnackBar('Invalid mobile number', context);
                                              } else {
                                                ContactDetails contactDetails = ContactDetails();
                                                contactDetails.MobCountryCode = selectedCityCountryCode;
                                                contactDetails.MobileNumber = mobileNumberController.text.toString().trim();
                                                contactDetails.Name = contactPersonController.text.toString().trim();
                                                contactPersonController.text = "";
                                                mobileNumberController.text = "";
                                                Navigator.of(context).pop(contactDetails);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).then((value) => {
                                  setState(() {
                                    ContactDetails contactDetail = value;
                                    contactDetailsList.add(contactDetail);
                                  })
                                });
                          },
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            color: Theme.of(context).colorScheme.surface,
                            child: Image.asset(
                              'assets/images/ic_add.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    contactDetailsList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: contactDetailsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            CustomTextView(
                                              label: contactDetailsList[index].Name,
                                              textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                                    color: textColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            CustomTextView(
                                                label: contactDetailsList[index].MobileNumber,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 17.0)),
                                            const SizedBox(
                                              height: 5.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          contactDetailsList.removeAt(index);
                                          setState(() {});
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/ic_cancel_black.png",
                                              height: 20,
                                              width: 20,
                                            ),
                                            const SizedBox(
                                              width: 2.0,
                                            ),
                                            CustomTextView(
                                              label: 'Remove',
                                              type: styleSubTitle,
                                              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: textColor.withOpacity(0.5),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(
                                    height: 2,
                                    color: Theme.of(context).colorScheme.outline,
                                  )
                                ],
                              );
                            })
                        : Container(),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: regNum,
                      read: false,
                      obscureText: false,
                      maxlines: 1,
                      maxlength: 4,
                      inputformat: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                      fillColor: Theme.of(context).colorScheme.surface,
                      labelText: 'Registration Number (UEN)',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    MyButtonWithoutBackground(
                        text: "Next",
                        textcolor: textColor,
                        textsize: 16,
                        fontWeight: FontWeight.w600,
                        letterspacing: 0.7,
                        buttoncolor: Theme.of(context).colorScheme.surface,
                        buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                        buttonheight: 60,
                        buttonwidth: width,
                        radius: 15,
                        onTap: () async {
                          hideKeyboard();
                          if (formKey.currentState!.validate()) {
                            validatePage();
                          }
                        }),
                    const SizedBox(
                      height: 30,
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
                      // final serviceStatus = await Permission.camera.isGranted;
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
      _cropImage(pickedFile);
      // final byte = await File(pickedFile.path).length();
      // final kb = byte / 1024;
      // final mb = kb / 1024;
      // debugPrint("File size -> ${mb.toString()}");
      // if (mb < 10.0) {
      //   await _progressDialog.hide();
      //   profilepic = File(pickedFile.path);
      //   selectedimage.add(profilepic!);
      //   setState(() {});
      // } else {
      //   await _progressDialog.hide();
      //   setState(() {});
      //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
      // }
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
      _cropImage(pickedFile);
      // final byte = await File(pickedFile.path).length();
      // final kb = byte / 1024;
      // final mb = kb / 1024;
      // debugPrint("File size -> ${mb.toString()}");
      // if (mb < 10.0) {
      //   await _progressDialog.hide();
      //   profilepic = File(pickedFile.path);
      //   setState(() {});
      //   selectedimage.add(profilepic!);
      // } else {
      //   await _progressDialog.hide();
      //   setState(() {});
      //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
      // }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> _cropImage(XFile pickedFile) async {
    var mCroppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (mCroppedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        croppedFile = mCroppedFile;
        setState(() {});
        selectedimage.add(File(croppedFile!.path));
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

  void checkForSelectedCity() {
    List<DataBean> selectedCityList = location!.where((element) => element.CountryName == choosedlocation).toList();
    selectedCityId = selectedCityList[0].CityId;
    _commonPassingArgs.selectedCityDetails = selectedCityList;
  }

  Future<void> getAllCity() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).getAllCities().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            LocationSelectionResponseModel? locationSelectionResponseModel = LocationSelectionResponseModel.fromMap(jsonDecode(res.body));
            if (locationSelectionResponseModel!.Data!.isNotEmpty) {
              await _progressDialog.hide();
              setState(() {
                location = locationSelectionResponseModel.Data!;
              });
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void validatePage() async {
    // if (choosedlocation != null) {
    //   if (profilepic == null) {
    //     setPassingArgsAndNavigate();
    //   } else {
    //     final bytes = File(profilepic!.path).readAsBytesSync();
    //     String convertedBytes = base64Encode(bytes);
    //     print(convertedBytes);
    //     print(profilepic!.path);
    //     print(profilepic!.path.split('/').last);
    //     print(profilepic!.path.split('/').last.split('.')[1]);
    //     uploadFile(convertedBytes);
    //   }
    // } else {
    //   Fluttertoast.showToast(
    //       msg: 'Please select city',
    //       fontSize: 15.0,
    //       backgroundColor: OQDOThemeData.dividerColor,
    //       textColor: OQDOThemeData.whiteColor,
    //       toastLength: Toast.LENGTH_SHORT);
    // }

    if (choosedlocation != null) {
      if (croppedFile == null) {
        showSnackBar('Profile image required', context);
      } else if (contactDetailsList.isEmpty) {
        showSnackBar('At least one contact is mandatory', context);
      } else if (address.text.toString().trim().isEmpty) {
        showSnackBar('Facility address required', context);
      } else if (postalcode.text.toString().trim().isNotEmpty && postalcode.text.toString().trim().length < 6) {
        showSnackBar('6 digit postal code is required', context);
      } else {
        _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
        _progressDialog.style(message: "Please wait..");
        await _progressDialog.show();
        // final bytes = File(croppedFile!.path).readAsBytesSync();
        // String convertedBytes = base64Encode(bytes);
        // debugPrint(convertedBytes);
        // debugPrint(croppedFile!.path);
        // debugPrint(croppedFile!.path.split('/').last);
        // debugPrint(croppedFile!.path.split('/').last.split('.')[1]);
        uploadFile();
      }
    } else {
      showSnackBar('Please select city', context);
    }
  }

  Future<void> uploadFile() async {
    var bytes = File(croppedFile!.path).readAsBytesSync();
    String convertedBytes = base64Encode(bytes);

    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] = croppedFile!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = convertedBytes;

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            _commonPassingArgs.profileImageUploadId = uploadFileResponse.FileStorageId.toString();
            setPassingArgsAndNavigate();
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void setPassingArgsAndNavigate() {
    // _commonPassingArgs.facilityName = facilityName.text.toString().trim();
    _commonPassingArgs.postalCode = postalcode.text.toString().trim();
    _commonPassingArgs.address = address.text.toString().trim();
    // _commonPassingArgs.FacilityProviderContactDtos = [];
    _commonPassingArgs.registrationNumberUEN = regNum.text.toString().trim();
    _commonPassingArgs.FacilityProviderContactDtos = contactDetailsList;
    debugPrint(_commonPassingArgs.registrationNumberUEN);
    Navigator.of(context).pushNamed(Constants.FACILITYADDTWO, arguments: _commonPassingArgs);
  }

  Future<void> showContactBottomSheet() => showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextView(
                      label: 'Contact Details',
                      textStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(color: textColor, fontWeight: FontWeight.w400, fontSize: 16.0),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(context);
                        },
                        child: const Icon(Icons.close, size: 30.0)),
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                CustomTextFormField(
                  controller: contactPersonController,
                  read: true,
                  obscureText: false,
                  maxlines: 1,
                  inputformat: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]+')),
                  ],
                  maxlength: 50,
                  labelText: 'Person Name',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                mobileNoLength! > 0
                    ? CustomTextFormField(
                        controller: mobileNumberController,
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: mobileNoLength,
                        labelText: 'Mobile Number',
                        keyboardType: TextInputType.number,
                      )
                    : CustomTextFormField(
                        controller: mobileNumberController,
                        read: false,
                        obscureText: false,
                        maxlines: 1,
                        maxlength: 12,
                        labelText: 'Mobile Number',
                        keyboardType: TextInputType.number,
                      ),
                const SizedBox(
                  height: 30.0,
                ),
                MyButton(
                  text: "Submit",
                  textcolor: textColor,
                  textsize: 16,
                  fontWeight: FontWeight.w600,
                  letterspacing: 0.7,
                  buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                  buttonheight: 60,
                  buttonwidth: width,
                  radius: 15,
                  onTap: () async {
                    if (contactPersonController.text.toString().trim().isEmpty) {
                      showSnackBar('Person name required', context);
                    } else if (mobileNumberController.text.trim().isEmpty) {
                      showSnackBar('Mobile number required', context);
                    } else if (mobileNumberController.text.toString().trim().length < mobileNoLength!) {
                      showSnackBar('Invalid mobile number', context);
                    } else {
                      ContactDetails contactDetails = ContactDetails();
                      contactDetails.MobCountryCode = selectedCityCountryCode!;
                      contactDetails.MobileNumber = mobileNumberController.text.toString().trim();
                      contactDetails.Name = contactPersonController.text.toString().trim();
                      Navigator.of(context).pop(contactDetails);
                      debugPrint(mobileNumberController.text.toString().trim());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      });
}
