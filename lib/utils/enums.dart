enum PayoutMethodTypeEnum {
  payNow('PN', 'PayNow'),
  payLah('PL', 'PayLah'),
  bankDetails('BD', 'BankDetail');

  final String value;
  final String displayText;

  const PayoutMethodTypeEnum(this.value, this.displayText);

  static PayoutMethodTypeEnum? getEnumFromString(String? value) {
    for (var element in PayoutMethodTypeEnum.values) {
      if (element.value == value) {
        return element;
      }
    }
    return null;
  }
}