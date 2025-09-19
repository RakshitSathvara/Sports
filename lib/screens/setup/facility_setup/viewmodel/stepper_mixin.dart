enum LoaderState { ideal, showLoader, hideLoader }

mixin StepperMixin {

  String _onError = "";
  String get getError => _onError;
  void setError({String? error = ""}) {
    _onError = error!;
  }

  String _onInfo = "";
  String get getInfo => _onInfo;
  void setInfo({String? info = ""}) {
    _onInfo = info!;
  }

  LoaderState _loaderState = LoaderState.ideal;
  LoaderState get getLoaderState => _loaderState;
  void setLoaderState({LoaderState? state = LoaderState.ideal}) {
    _loaderState = state!;
  }

  // Private variables
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Getters
  int get currentStep => _currentStep;

  int get totalSteps => _totalSteps;

  double get progress => _currentStep / _totalSteps;

  int get progressPercentage => (progress * 100).round();

  bool get isFirstStep => _currentStep == 1;

  bool get isLastStep => _currentStep == _totalSteps;

  bool get canGoPrevious => !isFirstStep;

  // Setters
  void incrementCurrentStep(){
    _currentStep ++;
  }
  void decrementCurrentStep(){
    _currentStep --;
  }

}
