/// email : "john.da4444vaqqqoe@example.com"
/// first_name : "John"
/// last_name : "Doe"
/// password : "asbdasndb@#mcnvcnvb585"
/// phone : "(555) 555-5555"
/// meta_data : [{"key":"user_age","value":"25"},{"key":"user_sex","value":"male"},{"key":"user_dob","value":"1995-06-21"},{"key":"emergency_email","value":"djhgdsjfg@gmail.com"},{"key":"emergency_phone","value":"9966554477"}]

class AddSlotModel {
  bool? sunday;
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  List<SlotList>? slotList;
  List<int>? selectedDaysList;

  static AddSlotModel? fromMap(Map<String, dynamic> map) {
    // if (map == null) return null;
    AddSlotModel createCustomerBean = AddSlotModel();
    createCustomerBean.sunday = map['sunday'];
    createCustomerBean.monday = map['monday'];
    createCustomerBean.tuesday = map['tuesday'];
    createCustomerBean.wednesday = map['wednesday'];
    createCustomerBean.thursday = map['thursday'];
    createCustomerBean.friday = map['friday'];
    createCustomerBean.saturday = map['saturday'];
    createCustomerBean.slotList = []..addAll((map['slot_list'] as List).map((o) => SlotList.fromMap(o)!));
    return createCustomerBean;
  }

  Map<String, dynamic> toJson() => {
        "sunday": sunday,
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thursday": thursday,
        "friday": friday,
        "saturday": saturday,
        "slot_list": slotList,
        "selected_days": selectedDaysList
      };
}

/// key : "user_age"
/// value : "25"

class SlotList {
  String? startTime;
  String? endTime;
  int? totalSlot;
  int? startTimeInMinutes;
  int? endTimeInMinutes;

  SlotList({this.startTime, this.endTime, this.totalSlot});

  static SlotList? fromMap(Map<String, dynamic> map) {
    // if (map == null) return null;
    SlotList metaDataBean = SlotList();
    metaDataBean.startTime = map['start_time'];
    metaDataBean.endTime = map['end_time'];
    metaDataBean.totalSlot = map['total_slot'];
    return metaDataBean;
  }

  Map toJson() => {
        "start_time": startTime,
        "end_time": endTime,
        "total_slot": totalSlot,
      };
}
