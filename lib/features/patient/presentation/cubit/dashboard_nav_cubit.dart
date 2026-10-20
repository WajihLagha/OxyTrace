import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardNavCubit extends Cubit<int> {
  DashboardNavCubit() : super(0);

  void selectTab(int index) => emit(index);
}
