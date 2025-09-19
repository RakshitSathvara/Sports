import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/coach_training_address.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/repository/service_provider_repository/service_provider_repository_impl.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/models/coach_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/grid_view_item_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/time_input_field.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/stepper_mixin.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

enum BookingSlotSheetState { ideal, hide }

enum AddressBottomSheetState { ideal, show }

enum CoachSetupState { ideal, success, failure }

class CreateCoachViewModel extends ChangeNotifier with StepperMixin {
  bool isEdit = false;

  final GetCoachBySetupIdModel? getCoachBySetupIdModel;

  CreateCoachViewModel({required this.getCoachBySetupIdModel}) {
    if (getCoachBySetupIdModel != null) {
      setCoachData(getCoachBySetupIdModel);
      return;
    }
    getActivityAndSubActivity();
  }

  final _serviceProviderSetupRepositoryImpl = ServiceProviderSetupRepositoryImpl();

  ProgressDialog? progressDialog;

  CoachSetupState setupState = CoachSetupState.ideal;

  void onBackPressed(BuildContext context) {
    hideKeyboard();
    if (currentStep == 1) {
      Navigator.of(context).pop();
    } else if (currentStep == 2) {
      decrementCurrentStep();
      notifyListeners();
    } else {
      decrementCurrentStep();
      notifyListeners();
    }
  }

  void nextStep() {
    if (!isLastStep) {
      hideKeyboard();
      if (currentStep == 1) {
        final isValidate = validateFirstStep();
        if (isValidate) {
          incrementCurrentStep();
          notifyListeners();
        }
      } else {
        final isValidate = validateSecondStep();
        if (isValidate) {
          incrementCurrentStep();
          notifyListeners();
        }
      }
    }
  }

  void previousStep() {
    if (canGoPrevious) {
      if (currentStep == 2) {
      } else if (currentStep == 3) {}
      decrementCurrentStep();
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////// Step 1 ////////////////////////////////////////////////

  final titleController = TextEditingController();
  final firstStepFormKey = GlobalKey<FormState>();

  List<ActivityBean> _activityListModel = [];

  String get selectedActivityName => _activityListModel.firstOrNull?.Name ?? "";
  List<SubActivitiesBean> subActivityList = [];
  SubActivitiesBean? selectedSubActivity;
  List<CoachTrainingAddress>? coachTrainingAddressList = [];

  final List<GridViewItemModel> trainingTypes = [
    GridViewItemModel(id: 1, imagePath: "assets/images/ic_open_class.png", title: "Open Class"),
    GridViewItemModel(id: 2, imagePath: "assets/images/ic_group_class.png", title: "Group Class"),
  ];

  GridViewItemModel? selectedTrainingType;

  // function to select activity
  void onSelectActivity(SubActivitiesBean item) {
    hideKeyboard();
    if (selectedSubActivity?.SubActivityId == item.SubActivityId) return;
    selectedSubActivity = item;
    notifyListeners();
  }

  // function to select activity
  void onSelectTrainingType(GridViewItemModel item) {
    hideKeyboard();
    if (selectedTrainingType?.id == item.id) return;
    selectedTrainingType = item;
    classCapacityController.clear();
    trainingLocationCheckBoxValue = 0;
    selectedAddress = null;
    notifyListeners();
  }

  bool validateFirstStep() {
    bool result = true;
    if (!(firstStepFormKey.currentState!.validate())) {
      return false;
    } else if (selectedSubActivity == null) {
      setError(error: "Please select Activity");
      notifyListeners();
      return false;
    } else if (selectedTrainingType == null) {
      setError(error: "Please select Training Type");
      notifyListeners();
      return false;
    }
    return result;
  }

  Future<void> getActivityAndSubActivity() async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();
    try {
      GetAllActivityAndSubActivityResponse getAllActivityAndSubActivityResponse =
          await _serviceProviderSetupRepositoryImpl.getCoachActivityAndSubActivity(OQDOApplication.instance.coachID ?? "");
      if (getAllActivityAndSubActivityResponse.Data!.isNotEmpty) {
        _activityListModel = getAllActivityAndSubActivityResponse.Data!;
        if (_activityListModel.isNotEmpty) {
          subActivityList = _activityListModel.first.SubActivities ?? [];
        }
        await getCoachTrainingCenterAddress();
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on CommonException catch (error) {
      debugPrint(error.message);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  Future<void> getCoachTrainingCenterAddress() async {
    try {
      var coachTrainingAddress = await _serviceProviderSetupRepositoryImpl.getCoachTrainingCenter(OQDOApplication.instance.coachID ?? "");
      debugPrint("Coach training address -> $coachTrainingAddress");
      coachTrainingAddressList = coachTrainingAddress;
    } on CommonException catch (errorResponse) {
      debugPrint(errorResponse.toString());
      setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
    } catch (error) {
      debugPrint(error.toString());
      setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
    }
  }

  ////////////////////////////////////////////////// Step 2 ////////////////////////////////////////////////

  bool isSlotTimeChangeRequestAccepted = true;

  final classCapacityController = TextEditingController();
  final classDurationController = TextEditingController();
  final minSessionController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final secondStepFormKey = GlobalKey<FormState>();
  final addAddressFormKey = GlobalKey<FormState>();
  final nameOfAddressController = TextEditingController();
  final addressLineOneController = TextEditingController();
  final addressLineTwoController = TextEditingController();
  final pincodeController = TextEditingController();

  // Store previous class duration for reverting changes
  String _previousClassDuration = "";

  /// Popular durations list for quick selection
  final List<String> popularDurations = ['01:00', '01:15', '01:30', '01:45', '02:00', '02:15', '02:30'];

  /// Convert duration string from HH:MM format to hours integer (for slot duration display)
  int getClassDurationInHours() {
    final durationText = classDurationController.text.trim();
    if (durationText.contains(':')) {
      // Parse HH:MM format - return only the hours part for slot duration display
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        return hours;
      }
    }
    // Fall back to parsing as simple integer
    return int.tryParse(durationText) ?? 0;
  }

  /// Convert duration string to total minutes for API calls
  int getClassDurationInMinutes() {
    final durationText = classDurationController.text.trim();
    if (durationText.contains(':')) {
      // Parse HH:MM format
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;

        // Convert to total minutes
        return (hours * 60) + minutes;
      }
    }
    // Fall back to parsing as simple integer (assume hours)
    final hours = int.tryParse(durationText) ?? 0;
    return hours * 60;
  }

  /// Set class duration from total minutes to HH:MM format
  void setClassDurationFromMinutes(int totalMinutes) {
    if (totalMinutes > 0) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      final formatted = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      classDurationController.text = formatted;
    }
  }

  /// Set class duration from hours integer to HH:MM format (legacy method)
  void setClassDurationFromHours(int hours) {
    setClassDurationFromMinutes(hours * 60);
  }

  /// Store current class duration as previous (for reverting changes)
  void storePreviousClassDuration() {
    _previousClassDuration = classDurationController.text.trim();
  }

  /// Revert class duration to previous value
  void revertClassDurationChange() {
    if (_previousClassDuration.isNotEmpty) {
      classDurationController.text = _previousClassDuration;
    }
    notifyListeners();
  }

  /// Set class duration from popular durations
  void setClassDuration(String duration) {
    hideKeyboard();
    final currentDuration = classDurationController.text.trim();
    if (currentDuration == duration) return;

    // Store previous duration before changing
    storePreviousClassDuration();

    // Set the new duration
    classDurationController.text = duration;

    // Check if there are existing slots and trigger slot clearing if needed
    if (addedTimeSlotList.isNotEmpty) {
      // This will be handled by the UI layer through a callback
      _shouldShowClearSlotsDialog = true;
    }

    notifyListeners();
  }

  // Flag to indicate when slots clearing dialog should be shown
  bool _shouldShowClearSlotsDialog = false;
  bool get shouldShowClearSlotsDialog => _shouldShowClearSlotsDialog;

  void clearShouldShowClearSlotsDialogFlag() {
    _shouldShowClearSlotsDialog = false;
  }

  int get classDurationInMinutes => getClassDurationInMinutes();

  /// Format class duration for display (e.g., "4h 30m" or "2h")
  String getFormattedClassDurationForDisplay() {
    final durationText = classDurationController.text.trim();
    if (durationText.contains(':')) {
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;

        if (minutes == 0) {
          return hours == 1 ? '1 hour' : '$hours hours';
        } else {
          String hourText = hours == 1 ? '1 hour' : '$hours hours';
          String minuteText = minutes == 1 ? '1 minute' : '$minutes minutes';
          return hours > 0 ? '$hourText $minuteText' : minuteText;
        }
      }
    }
    // Fall back to simple hours format
    final hours = int.tryParse(durationText) ?? 0;
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  String getFormattedDurationForDisplay() {
    final durationText = classDurationController.text.trim();
    if (durationText.contains(':')) {
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;

        if (minutes == 0) {
          return '${hours}h';
        } else {
          return '${hours}h ${minutes}m';
        }
      }
    }
    // Fall back to simple hours format
    final hours = int.tryParse(durationText) ?? 0;
    return '${hours}h';
  }

  /// Calculate formatted total duration for display (numberOfSlots * classDuration)
  String getFormattedTotalClassDurationForDisplay(int numberOfSlots) {
    final durationMinutes = getClassDurationInMinutes();
    final totalMinutes = numberOfSlots * durationMinutes;

    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;

    if (remainingMinutes == 0) {
      return totalHours == 1 ? '1 hour' : '$totalHours hours';
    } else {
      String hourText = totalHours == 1 ? '1 hour' : '$totalHours hours';
      String minuteText = remainingMinutes == 1 ? '1 minute' : '$remainingMinutes minutes';
      return totalHours > 0 ? '$hourText $minuteText' : minuteText;
    }
  }

  int classCapacity = 0;

  bool isSameRates = false;

  CoachTrainingAddress? selectedAddress;

  // 1 = At Coach's Address, 2 = Home Training, 3 = Both Options Available
  int trainingLocationCheckBoxValue = 0;

  Timer? _debounceTimer;

  void onSelectTrainingVenue(value) {
    isTrainingLocationChanged = true;
    selectedAddress = value;
    notifyListeners();
  }

  void onAcceptSlotTimeChangeRequest() {
    isSlotTimeChangeRequestAccepted = true;
    addedTimeSlotList.clear();
    notifyListeners();
  }

  void onClickOfSaveAddress() async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();
    final isAdded = await addCoachTrainingAddress();
    if (isAdded) {
      selectedAddress = coachTrainingAddressList?.where((element) => element.addressName == nameOfAddressController.text.trim()).firstOrNull;
      isTrainingLocationChanged = true;
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
      clearAddressSheetData();
    } else {
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 250));
      addressBottomSheetState = AddressBottomSheetState.show;
      notifyListeners();
    }
  }

  void clearAddressSheetData() {
    nameOfAddressController.clear();
    addressLineOneController.clear();
    addressLineTwoController.clear();
    pincodeController.clear();
  }

  void onToggleSameRatesSwitch(bool value) {
    hideKeyboard();
    isSameRates = value;
    if (!isSameRates) {
      hourlyRateController.clear();
    }
    notifyListeners();
  }

  bool validateSecondStep() {
    bool result = true;
    final isGroupClass = selectedTrainingType?.id == 2;
    if (!(secondStepFormKey.currentState!.validate())) {
      return false;
    } else if (isGroupClass || classCapacity == 1) {
      if (trainingLocationCheckBoxValue == 0) {
        setError(error: "Please select Training Location");
        notifyListeners();
        return false;
      } else if ((trainingLocationCheckBoxValue != 2) && selectedAddress == null) {
        setError(error: "Please Add/Select address");
        notifyListeners();
        return false;
      }
    } else {
      if (selectedAddress == null) {
        setError(error: "Please Add/Select address");
        notifyListeners();
        return false;
      }
    }
    return result;
  }

  void onChangeTrainingLocationCheckBoxValue(int value) {
    hideKeyboard();
    if (trainingLocationCheckBoxValue == value) return;
    trainingLocationCheckBoxValue = value;
    if (value == 2) {
      selectedAddress = null;
    }
    notifyListeners();
  }

  void stepThreeDataClear() {
    classCapacityController.clear();
    classDurationController.clear();
    minSessionController.clear();
    hourlyRateController.clear();
    trainingLocationCheckBoxValue = 0;
    selectedAddress = null;
  }

  void onChangeClassCapacity(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      trainingLocationCheckBoxValue = 0;
      selectedAddress = null;
      classCapacity = (int.tryParse(val.trim()) ?? 0);
      notifyListeners();
    });
  }

  Future<bool> addCoachTrainingAddress() async {
    // setLoaderState(state: LoaderState.showLoader);
    // notifyListeners();
    try {
      final cityId = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
      Map addressMap = {};
      addressMap['CoachId'] = OQDOApplication.instance.coachID;
      addressMap['SubActivityId'] = selectedSubActivity?.SubActivityId;
      addressMap['AddressName'] = nameOfAddressController.text.trim();
      addressMap['Address1'] = addressLineOneController.text.trim();
      addressMap['Address2'] = addressLineTwoController.text..trim();
      addressMap['CityId'] = cityId;
      addressMap['PinCode'] = pincodeController.text.trim();
      debugPrint(json.encode(addressMap));

      var response = await _serviceProviderSetupRepositoryImpl.addCoachTrainingAddress(addressMap, false);
      debugPrint("dd Address Response ====> $response");

      await getCoachTrainingCenterAddress();
      return true;
    } on CommonException catch (error) {
      debugPrint("Add Address error ====> ${error.toString()}");
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0] ?? "");
          } else {
            setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      }
      // setLoaderState(state: LoaderState.hideLoader);
      // notifyListeners();
      return false;
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      // setLoaderState(state: LoaderState.hideLoader);
      // notifyListeners();
      return false;
    } catch (error) {
      debugPrint("Add Address error in Catch Block ====> ${error.toString()}");
      // setLoaderState(state: LoaderState.hideLoader);
      // notifyListeners();
      return false;
    }
  }

  //////////////////////////////////////////////// Add Slot variables ////////////////////////////////////////////////

  BookingSlotSheetState bookingSlotSheetState = BookingSlotSheetState.ideal;

  AddressBottomSheetState addressBottomSheetState = AddressBottomSheetState.ideal;

  final slotFormKey = GlobalKey<FormState>();

  CoachPreviewModel? coachPreview;

  List<AddTimeSlotModel> addedTimeSlotList = [];
  List<AddTimeSlotModel> editTimeSlotList = [];

  final List<String> popularTimes = ['06:00', '08:00', '10:00', '14:00', '16:00', '18:00', '20:00'];

  final List<GridViewItemModel> days = [
    GridViewItemModel(id: 1, imagePath: "", title: "Mon"),
    GridViewItemModel(id: 2, imagePath: "", title: "Tue"),
    GridViewItemModel(id: 3, imagePath: "", title: "Wed"),
    GridViewItemModel(id: 4, imagePath: "", title: "Thu"),
    GridViewItemModel(id: 5, imagePath: "", title: "Fri"),
    GridViewItemModel(id: 6, imagePath: "", title: "Sat"),
    GridViewItemModel(id: 0, imagePath: "", title: "Sun"),
  ];

  List<GridViewItemModel> _selectedDays = [];

  List<GridViewItemModel> get selectedDays => _selectedDays;

  void toggleDay(GridViewItemModel day) {
    if (_selectedDays.contains(day)) {
      _selectedDays = List.from(_selectedDays)..remove(day);
    } else {
      _selectedDays = List.from(_selectedDays)..add(day);
    }
    notifyListeners();
  }

  void setStartTime(String time, int index) {
    hideKeyboard();
    final currentAddedTime = editTimeSlotList[index].startTime.text;
    if (currentAddedTime == time) return;
    editTimeSlotList[index].startTimeControllerKey.currentState?.setTime(time);
  }

  void clearSelectionOfAddTimeBottomSheet() {
    _selectedDays.clear();
    editTimeSlotList.clear();
    if (!isSameRates) {
      hourlyRateController.clear();
    }
    notifyListeners();
  }

  void onClickOfAddTimeSlot() {
    hideKeyboard();
    if (_selectedDays.isEmpty) {
      setError(error: "Please select at least one Training Day");
      notifyListeners();
      return;
    }
    if (!isSameRates && (!(slotFormKey.currentState?.validate() ?? false))) {
      return;
    }
    if (editTimeSlotList.isEmpty) {
      setError(error: "Please add at least one Training Session");
      notifyListeners();
      return;
    }
    for (var element in editTimeSlotList) {
      if (element.startTime.text.isEmpty) {
        setError(error: "Please select/enter Start Time in current entry");
        notifyListeners();
        return;
      } else if (element.startTimeControllerKey.currentState?.hasError ?? true) {
        return;
      } else if ((!(element.formKey.currentState?.validate() ?? false))) {
        return;
      }
      if (!(slotFormKey.currentState?.validate() ?? false)) {
        return;
      }
      element.selectedDays.clear();
      element.selectedDays.addAll(_selectedDays);
      element.ratePerHour = double.tryParse(hourlyRateController.text.trim());
    }

    isSlotsChanged = true;
    addedTimeSlotList.addAll(editTimeSlotList);
    bookingSlotSheetState = BookingSlotSheetState.hide;
    isSlotTimeChangeRequestAccepted = false;
    notifyListeners();
    clearSelectionOfAddTimeBottomSheet();
  }

  void onTapAddTimeSlot() {
    hideKeyboard();
    if (selectedDays.isEmpty) {
      setError(error: "Please select at least one Training Day");
      notifyListeners();
      return;
    }
    if (editTimeSlotList.isEmpty) {
      editTimeSlotList.add(
        AddTimeSlotModel(
          selectedDays: [],
          formKey: GlobalKey<FormState>(),
          startTime: TextEditingController(),
          numberOfSlots: TextEditingController(),
          perSlotDuration: getClassDurationInHours(),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
        ),
      );
    } else {
      for (var element in editTimeSlotList) {
        if (element.startTime.text.isEmpty) {
          setError(error: "Please select/enter Start Time in current entry");
          notifyListeners();
          return;
        } else if ((!(element.formKey.currentState?.validate() ?? false))) {
          return;
        }
      }
      editTimeSlotList.add(
        AddTimeSlotModel(
          selectedDays: [],
          formKey: GlobalKey<FormState>(),
          startTime: TextEditingController(),
          numberOfSlots: TextEditingController(),
          perSlotDuration: getClassDurationInHours(),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
        ),
      );
    }
    notifyListeners();
  }

  void onClearSession(int index) {
    editTimeSlotList.removeAt(index);
    notifyListeners();
  }

  void onRemoveAddedSlot(int index) {
    addedTimeSlotList.removeAt(index);
    isSlotsChanged = true;
    notifyListeners();
  }

  void clearNumberOfSlots(AddTimeSlotModel editSlot) {
    editSlot.numberOfSlots.clear();
    notifyListeners();
  }

  double tempSlotRates = 0.0;

  void addBatchSetupCall() {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();

    final bookingType = (selectedTrainingType?.id == 1) ? "I" : "G";
    final isTrainingAddress = ((trainingLocationCheckBoxValue == 1) || (trainingLocationCheckBoxValue == 3));
    final isTraineeAddress = ((trainingLocationCheckBoxValue == 2) || (trainingLocationCheckBoxValue == 3));

    Map addBatchSlotMap = {};
    addBatchSlotMap['CoachBatchSetupId'] = isEdit ? getCoachBySetupIdModel?.coachBatchSetupId : '';
    addBatchSlotMap['CoachId'] = OQDOApplication.instance.coachID;
    addBatchSlotMap['SubActivityId'] = selectedSubActivity?.SubActivityId;

    Map coachSetupInnerMap = {};
    coachSetupInnerMap['CoachBatchSetupDetailId'] = '';
    coachSetupInnerMap['CoachBatchSetupId'] = isEdit ? getCoachBySetupIdModel?.coachBatchSetupId : '';
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now);
    coachSetupInnerMap['EffectiveDate'] = formattedDate;
    coachSetupInnerMap['BookingType'] = bookingType;
    coachSetupInnerMap['Name'] = titleController.text.trim();
    coachSetupInnerMap['SlotTimeMinute'] = classDurationInMinutes;
    coachSetupInnerMap['RatePerHour'] = isSameRates ? hourlyRateController.text.trim() : null;
    coachSetupInnerMap['BatchCapacity'] = bookingType == "G" ? 1 : classCapacityController.text.trim();
    coachSetupInnerMap['IsTrainingAddress'] = isTrainingAddress;
    coachSetupInnerMap['IsSameSlotRate'] = isSameRates;
    coachSetupInnerMap['MinimumSlot'] = minSessionController.text.trim();
    coachSetupInnerMap['MaxGroupSize'] = bookingType == "G" ? classCapacityController.text.trim() : null;

    Map trainingAddressMap = {};
    trainingAddressMap['AddressId'] = selectedAddress?.coachTrainingAddressId;

    if (isTrainingAddress) {
      coachSetupInnerMap['coachBatchSetupAddressDtos'] = [trainingAddressMap];
    }
    coachSetupInnerMap['IsTraineeAddress'] = isTraineeAddress;
    coachSetupInnerMap['IsActive'] = true;

    List<Map> slotList = [];
    tempSlotRates = addedTimeSlotList.first.ratePerHour ?? 0.00;
    for (int i = 0; i < addedTimeSlotList.length; i++) {
      Map slotMap = {};
      final slotsModel = addedTimeSlotList[i];
      slotMap['DayNos'] = slotsModel.sortedSelectedDays.map((element) => element.id).toList();
      slotMap['StartTimeInMinute'] = slotsModel.startTimeInMinutes;
      slotMap['NoOfSlot'] = slotsModel.tempNumberOfSlots;
      slotMap['EndTimeInMinute'] = slotsModel.endTimeInMinutes;
      slotMap['RatePerHour'] = slotsModel.ratePerHour;
      tempSlotRates = tempSlotRates < slotsModel.ratePerHour! ? tempSlotRates : slotsModel.ratePerHour!;
      slotList.add(slotMap);
    }
    coachSetupInnerMap['coachBatchSetupDaySlotDtos'] = slotList;
    addBatchSlotMap['CoachBatchSetupDetailDtos'] = [coachSetupInnerMap];
    debugPrint("Create Coach Request ===> ${json.encode(addBatchSlotMap)}");
    callBatchSetup(addBatchSlotMap);
    coachPreview = CoachPreviewModel(
      title: titleController.text.trim(),
      activity: selectedActivityName,
      subActivity: selectedSubActivity?.Name ?? "",
      slotDuration: getClassDurationInHours(), // Use proper duration method
      slotDurationInMinutes: getClassDurationInMinutes(), // Add duration in minutes
      slotDurationFormatted: getFormattedDurationForDisplay(), // Add formatted duration
      slotRate: tempSlotRates,
      maxCapacityOrGroupSize: classCapacity.toString(),
      isOpenClass: bookingType == "I",
      slotsList: addedTimeSlotList,
      addressTypeId: trainingLocationCheckBoxValue,
      minSessions: minSessionController.text.trim(),
    );
  }

  Future<void> callBatchSetup(Map addBatchSlotMap) async {
    try {
      var response = "";
      if (isEdit) {
        response = await _serviceProviderSetupRepositoryImpl.editCoachBatch(addBatchSlotMap);
      } else {
        response = await _serviceProviderSetupRepositoryImpl.addCoachbatch(addBatchSlotMap);
      }

      if (response.isNotEmpty) {
        setInfo(info: 'Batch added successfully');
        // After successful save/edit, fetch latest data and show preview
        await _fetchCoachDataAndShowPreview(response);
      } else {
        setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0] ?? "");
          } else {
            setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  ///////////////////////////////////////// EDIT TIME Variables & Methods ////////////////////////////////////

  String? previousPrice;
  String? previousCapacity;
  int? previousTrainingLocationValue;
  String? previousClassDuration;
  String? previousMinSession;
  String? previousName;

  bool isPriceChanged = false;
  bool isCapacityChanged = false;
  bool isTrainingLocationChanged = false;
  bool isClassDurationChanged = false;
  bool isMinSessionChanged = false;
  bool isSlotsChanged = false;
  bool isNameChanged = false;

  Future<void> setCoachData(GetCoachBySetupIdModel? getCoachBySetupIdModel) async {
    if (getCoachBySetupIdModel == null) return;

    isEdit = true;

    try {
      await getActivityAndSubActivity();

      titleController.text = getCoachBySetupIdModel.name ?? '';
      previousName = titleController.text.trim();

      if (getCoachBySetupIdModel.subActivityId != null) {
        selectedSubActivity = subActivityList.firstWhere((activity) => activity.SubActivityId == getCoachBySetupIdModel.subActivityId, orElse: () => SubActivitiesBean());
      }

      final isGroupClass = getCoachBySetupIdModel.bookingType == 'G';
      selectedTrainingType = isGroupClass ? trainingTypes[1] : trainingTypes[0];

      if (getCoachBySetupIdModel.slotTimeMinute != null) {
        setClassDurationFromMinutes(getCoachBySetupIdModel.slotTimeMinute!);
        previousClassDuration = classDurationController.text.trim();
      }

      getCoachBySetupIdModel.bookingType == 'I'
          ? classCapacityController.text = getCoachBySetupIdModel.batchCapacity?.toString() ?? ""
          : classCapacityController.text = getCoachBySetupIdModel.maxGroupSize?.toString() ?? "";
      previousCapacity = classCapacityController.text.trim();

      // if (getCoachBySetupIdModel.batchCapacity != null) {
      // classCapacityController.text = getCoachBySetupIdModel.batchCapacity.toString();
      // classCapacity = getCoachBySetupIdModel.batchCapacity!;
      // previousCapacity = classCapacityController.text.trim();
      // }

      if (getCoachBySetupIdModel.minimumSlot != null) {
        minSessionController.text = getCoachBySetupIdModel.minimumSlot.toString();
        previousMinSession = minSessionController.text.trim();
      }

      isSameRates = getCoachBySetupIdModel.isSameSlotRate ?? false;
      if (getCoachBySetupIdModel.ratePerHour != null && isSameRates) {
        hourlyRateController.text = getCoachBySetupIdModel.ratePerHour.toString();
        previousPrice = hourlyRateController.text.trim();
      } else {
        previousPrice = "";
      }

      if (getCoachBySetupIdModel.isTrainingAddress == true && getCoachBySetupIdModel.isTraineeAddress == true) {
        trainingLocationCheckBoxValue = 3;
      } else if (getCoachBySetupIdModel.isTrainingAddress == true) {
        trainingLocationCheckBoxValue = 1;
      } else if (getCoachBySetupIdModel.isTraineeAddress == true) {
        trainingLocationCheckBoxValue = 2;
      }
      previousTrainingLocationValue = trainingLocationCheckBoxValue;

      if (getCoachBySetupIdModel.coachBatchSetupAddressDtos?.isNotEmpty == true) {
        final addressId = getCoachBySetupIdModel.coachBatchSetupAddressDtos!.first.addressId;
        if (addressId != null) {
          selectedAddress = coachTrainingAddressList?.firstWhere((address) => address.coachTrainingAddressId == addressId, orElse: () => CoachTrainingAddress());
        }
      }

      if (getCoachBySetupIdModel.slots?.isNotEmpty == true) {
        _populateTimeSlotsFromModel(getCoachBySetupIdModel.slots!);
        isSlotTimeChangeRequestAccepted = false;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting coach data: $e');
    }
  }

  void _populateTimeSlotsFromModel(List<Slots> slots) {
    addedTimeSlotList.clear();

    for (final slot in slots) {
      if (slot.dayNos?.isNotEmpty == true) {
        final selectedDaysList = slot.dayNos!
            .map((dayNo) => days.firstWhere((day) => day.id == dayNo, orElse: () => GridViewItemModel(id: dayNo, imagePath: "", title: "")))
            .where((day) => day.title.isNotEmpty)
            .toList();

        final startTimeController = TextEditingController();
        if (slot.startTimeFormatted != null) {
          startTimeController.text = slot.startTimeFormatted!;
        } else if (slot.startTimeInMinute != null) {
          final hours = slot.startTimeInMinute! ~/ 60;
          final minutes = slot.startTimeInMinute! % 60;
          startTimeController.text = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        }

        final numberOfSlotsController = TextEditingController();
        if (slot.noOfSlot != null) {
          numberOfSlotsController.text = slot.noOfSlot.toString();
        }

        final timeSlot = AddTimeSlotModel(
          selectedDays: selectedDaysList,
          formKey: GlobalKey<FormState>(),
          startTime: startTimeController,
          numberOfSlots: numberOfSlotsController,
          perSlotDuration: getClassDurationInHours(),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
          ratePerHour: slot.ratePerHour,
        );

        addedTimeSlotList.add(timeSlot);
      }
    }
  }

  Future<void> checkForChanges() async {
    if (previousName != titleController.text.trim()) {
      isNameChanged = true;
    }
    if (previousPrice != hourlyRateController.text.trim()) {
      isPriceChanged = true;
    }
    if (previousCapacity != classCapacityController.text.trim()) {
      isCapacityChanged = true;
    }
    if (previousTrainingLocationValue != trainingLocationCheckBoxValue) {
      isTrainingLocationChanged = true;
    }
    if (previousClassDuration != classDurationController.text.trim()) {
      isClassDurationChanged = true;
    }
    if (previousMinSession != minSessionController.text.trim()) {
      isMinSessionChanged = true;
    }
  }

  void updateBasicInfo() async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();

    final bookingType = (selectedTrainingType?.id == 1) ? "I" : "G";

    // API request now only contains CoachBatchSetupId and Title
    Map request = {};
    request['CoachBatchSetupDetailId'] = getCoachBySetupIdModel?.coachBatchSetupDetailId;
    request['Name'] = titleController.text.toString().trim();

    coachPreview = CoachPreviewModel(
      title: titleController.text.trim(),
      activity: selectedActivityName,
      subActivity: selectedSubActivity?.Name ?? "",
      slotDuration: getClassDurationInHours(),
      slotDurationInMinutes: getClassDurationInMinutes(),
      slotDurationFormatted: getFormattedDurationForDisplay(),
      slotRate: tempSlotRates,
      maxCapacityOrGroupSize: classCapacity.toString(),
      isOpenClass: bookingType == "I",
      slotsList: addedTimeSlotList,
      addressTypeId: trainingLocationCheckBoxValue,
      minSessions: minSessionController.text.trim(),
    );

    try {
      String response = await _serviceProviderSetupRepositoryImpl.updateCoachBasicInfo(request);
      debugPrint('updateBasicInfo -> $response');
      if (response.isNotEmpty) {
        setInfo(info: 'Coach updated successfully');
        // After successful update, fetch latest data and show preview
        await _fetchCoachDataAndShowPreview(getCoachBySetupIdModel?.coachBatchSetupId.toString() ?? "");
      } else {
        setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0] ?? "");
          } else {
            setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      setError(error: 'We\'re unable to connect to server. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  /// Fetch coach data by setup ID and show preview
  Future<void> _fetchCoachDataAndShowPreview(String apiResponse) async {
    try {
      int? setupId;

      // Determine the setup ID based on edit mode or parse from response
      if (isEdit && apiResponse.isNotEmpty) {
        setupId = int.tryParse(apiResponse);
      } else {
        // For create mode, try to parse the setup ID from the response

        // Response might be just the ID as a string
        setupId = int.tryParse(apiResponse);
      }

      if (setupId != null) {
        // Call getBatchById API to get latest data
        GetCoachBySetupIdModel updatedCoachData = await _serviceProviderSetupRepositoryImpl.getBatchById(setupId);

        // Convert to CoachPreviewModel
        coachPreview = _convertToCoachPreviewModel(updatedCoachData);

        setupState = CoachSetupState.success;
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      } else {
        setError(error: 'Unable to fetch coach data. Please try again.');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      debugPrint('Error fetching coach data: ${error.toString()}');
      setError(error: 'We\'re unable to fetch the latest data. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching coach data: ${error.toString()}');
      setError(error: 'We\'re unable to fetch the latest data. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  /// Convert GetCoachBySetupIdModel to CoachPreviewModel
  CoachPreviewModel _convertToCoachPreviewModel(GetCoachBySetupIdModel model) {
    // Calculate slot rate - use minimum rate from slots or ratePerHour
    double slotRate = 0.0;
    if (model.slots?.isNotEmpty == true) {
      slotRate = model.slots!.map((slot) => slot.ratePerHour ?? 0.0).reduce((a, b) => a < b ? a : b);
    } else if (model.ratePerHour != null) {
      slotRate = model.ratePerHour!;
    }

    // Determine address type ID
    int addressTypeId = 0;
    if (model.isTrainingAddress == true && model.isTraineeAddress == true) {
      addressTypeId = 3; // Both options available
    } else if (model.isTrainingAddress == true) {
      addressTypeId = 1; // At Coach's Address
    } else if (model.isTraineeAddress == true) {
      addressTypeId = 2; // Home Training
    }

    // Convert slots to AddTimeSlotModel list
    List<AddTimeSlotModel> slotsList = [];
    if (model.slots?.isNotEmpty == true) {
      for (final slot in model.slots!) {
        if (slot.dayNos?.isNotEmpty == true) {
          final selectedDaysList = slot.dayNos!
              .map((dayNo) => days.firstWhere((day) => day.id == dayNo, orElse: () => GridViewItemModel(id: dayNo, imagePath: "", title: "")))
              .where((day) => day.title.isNotEmpty)
              .toList();

          final startTimeController = TextEditingController();
          if (slot.startTimeFormatted != null) {
            startTimeController.text = slot.startTimeFormatted!;
          } else if (slot.startTimeInMinute != null) {
            final hours = slot.startTimeInMinute! ~/ 60;
            final minutes = slot.startTimeInMinute! % 60;
            startTimeController.text = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
          }

          final numberOfSlotsController = TextEditingController();
          if (slot.noOfSlot != null) {
            numberOfSlotsController.text = slot.noOfSlot.toString();
          }

          final timeSlot = AddTimeSlotModel(
            selectedDays: selectedDaysList,
            formKey: GlobalKey<FormState>(),
            startTime: startTimeController,
            numberOfSlots: numberOfSlotsController,
            perSlotDuration: (model.slotTimeMinute ?? 60) ~/ 60, // Convert minutes to hours
            startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
            ratePerHour: slot.ratePerHour,
          );

          slotsList.add(timeSlot);
        }
      }
    }

    // Format duration for display
    String formattedDuration = '';
    if (model.slotTimeMinute != null) {
      final hours = model.slotTimeMinute! ~/ 60;
      final minutes = model.slotTimeMinute! % 60;
      if (minutes == 0) {
        formattedDuration = '${hours}h';
      } else {
        formattedDuration = '${hours}h ${minutes}m';
      }
    }

    return CoachPreviewModel(
      title: model.name ?? '',
      activity: model.activities?.name ?? '',
      subActivity: model.subActivities?.name ?? '',
      slotDuration: (model.slotTimeMinute ?? 60) ~/ 60, // Convert minutes to hours
      slotDurationInMinutes: model.slotTimeMinute ?? 60,
      slotDurationFormatted: formattedDuration,
      slotRate: slotRate,
      maxCapacityOrGroupSize: model.bookingType == 'I' ? (model.batchCapacity?.toString() ?? '1') : (model.maxGroupSize?.toString() ?? '1'),
      minSessions: model.minimumSlot?.toString() ?? '1',
      isOpenClass: model.bookingType == 'I',
      addressTypeId: addressTypeId,
      slotsList: slotsList,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
