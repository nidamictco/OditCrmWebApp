import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'transfer_lead_report_state.dart';

class TransferLeadReportCubit extends Cubit<TransferLeadReportState> {
  TransferLeadReportCubit() : super(TransferLeadReportInitial());
}
