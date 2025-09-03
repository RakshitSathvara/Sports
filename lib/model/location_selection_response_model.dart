class LocationSelectionResponseModel {
  List<DataBean>? Data;
  int? TotalCount;
  int? PageStart;
  int? ResultPerPage;

  static LocationSelectionResponseModel? fromMap(Map<String, dynamic> map) {
    LocationSelectionResponseModel locationSelectionResponseModelBean = LocationSelectionResponseModel();
    locationSelectionResponseModelBean.Data = [...(map['Data'] as List).map((o) => DataBean.fromMap(o)!)];
    locationSelectionResponseModelBean.TotalCount = map['TotalCount'];
    locationSelectionResponseModelBean.PageStart = map['PageStart'];
    locationSelectionResponseModelBean.ResultPerPage = map['ResultPerPage'];
    return locationSelectionResponseModelBean;
  }

  Map toJson() => {
        "Data": Data,
        "TotalCount": TotalCount,
        "PageStart": PageStart,
        "ResultPerPage": ResultPerPage,
      };
}

class DataBean {
  int? CityId;
  String? Name;
  bool? IsActive;
  int? StateId;
  String? StateName;
  int? CountryId;
  String? CountryName;
  String? CountryCode;
  int? MobileNoLength;

  static DataBean? fromMap(Map<String, dynamic> map) {
    DataBean dataBean = DataBean();
    dataBean.CityId = map['CityId'];
    dataBean.Name = map['Name'];
    dataBean.IsActive = map['IsActive'];
    dataBean.StateId = map['StateId'];
    dataBean.StateName = map['StateName'];
    dataBean.CountryId = map['CountryId'];
    dataBean.CountryName = map['CountryName'];
    dataBean.CountryCode = map['CountryCode'];
    dataBean.MobileNoLength = map['MobileNoLength'];
    return dataBean;
  }

  Map toJson() => {
        "CityId": CityId,
        "Name": Name,
        "IsActive": IsActive,
        "StateId": StateId,
        "StateName": StateName,
        "CountryId": CountryId,
        "CountryName": CountryName,
        "CountryCode": CountryCode,
        "MobileNoLength": MobileNoLength,
      };
}
