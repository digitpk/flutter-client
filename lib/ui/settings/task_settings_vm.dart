import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/company_model.dart';
import 'package:invoiceninja_flutter/redux/company/company_actions.dart';
import 'package:invoiceninja_flutter/redux/settings/settings_actions.dart';
import 'package:invoiceninja_flutter/ui/settings/task_settings.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';

class TaskSettingsScreen extends StatelessWidget {
  const TaskSettingsScreen({Key key}) : super(key: key);
  static const String route = '/$kSettings/$kSettingsTasks';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TaskSettingsVM>(
      converter: TaskSettingsVM.fromStore,
      builder: (context, viewModel) {
        return TaskSettings(
          viewModel: viewModel,
          key: ValueKey(viewModel.state.settingsUIState.updatedAt),
        );
      },
    );
  }
}

class TaskSettingsVM {
  TaskSettingsVM({
    @required this.state,
    @required this.company,
    @required this.onCompanyChanged,
    @required this.onSavePressed,
    @required this.onConfigureStatusesPressed,
  });

  static TaskSettingsVM fromStore(Store<AppState> store) {
    final state = store.state;

    return TaskSettingsVM(
      state: state,
      company: state.uiState.settingsUIState.company,
      onCompanyChanged: (company) =>
          store.dispatch(UpdateCompany(company: company)),
      onSavePressed: (context) {
        final settingsUIState = state.uiState.settingsUIState;
        final completer = snackBarCompleter<Null>(
            context, AppLocalization.of(context).savedSettings);
        store.dispatch(SaveCompanyRequest(
            completer: completer, company: settingsUIState.company));
      },
      onConfigureStatusesPressed: (context) {
        store.dispatch(ViewSettings(
            navigator: Navigator.of(context), section: kSettingsTaskStatuses));
      },
    );
  }

  final AppState state;
  final Function(BuildContext) onSavePressed;
  final CompanyEntity company;
  final Function(CompanyEntity) onCompanyChanged;
  final Function(BuildContext) onConfigureStatusesPressed;
}