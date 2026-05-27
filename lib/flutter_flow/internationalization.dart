import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kAppLanguageKey = '__app_language__';

/// Idioma da app (PT / EN), persistido como no FlutterFlow.
class FFLocalizations {
  FFLocalizations._();

  static SharedPreferences? _prefs;
  static String _languageCode = 'pt';

  static String get languageCode => _languageCode;

  static Locale get locale => Locale(_languageCode);

  static const List<Locale> supportedLocales = [
    Locale('pt'),
    Locale('en'),
  ];

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _languageCode = _prefs?.getString(kAppLanguageKey) ?? 'pt';
    if (_languageCode != 'pt' && _languageCode != 'en') {
      _languageCode = 'pt';
    }
  }

  static Future<void> setLocale(String languageCode) async {
    if (languageCode != 'pt' && languageCode != 'en') {
      return;
    }
    _languageCode = languageCode;
    await _prefs?.setString(kAppLanguageKey, languageCode);
  }
}

/// Tradução por chave. Usa [FFLocalizations.languageCode] actual.
String tr(String key) {
  final translations = _kTranslations[key];
  if (translations == null) {
    return key;
  }
  final lang = FFLocalizations.languageCode;
  return translations[lang] ?? translations['pt'] ?? translations['en'] ?? key;
}

const Map<String, Map<String, String>> _kTranslations = {
  'settings.theme': {
    'pt': 'Tema',
    'en': 'Theme',
  },
  'settings.language': {
    'pt': 'Idioma',
    'en': 'Language',
  },
  'settings.light': {
    'pt': 'Modo claro',
    'en': 'Light mode',
  },
  'settings.dark': {
    'pt': 'Modo escuro',
    'en': 'Dark mode',
  },
  'settings.themeTest': {
    'pt': 'Área de teste do tema',
    'en': 'Theme test area',
  },
  'lang.pt': {
    'pt': 'Português',
    'en': 'Portuguese',
  },
  'lang.en': {
    'pt': 'Inglês',
    'en': 'English',
  },
  'nav.home': {
    'pt': 'Início',
    'en': 'Home',
  },
  'nav.history': {
    'pt': 'Histórico',
    'en': 'History',
  },
  'nav.reports': {
    'pt': 'Relatórios',
    'en': 'Reports',
  },
  'nav.settings': {
    'pt': 'Definições',
    'en': 'Settings',
  },
  'home.startShift': {
    'pt': 'Iniciar turno',
    'en': 'Start shift',
  },
  'home.addVehicle': {
    'pt': 'Adicionar veículo',
    'en': 'Add vehicle',
  },
  'home.registerVehicleFirst': {
    'pt': 'Regista o teu veículo antes do primeiro turno.',
    'en': 'Register your vehicle before your first shift.',
  },
  'home.pause': {
    'pt': 'PAUSA',
    'en': 'PAUSE',
  },
  'home.resume': {
    'pt': 'RETOMAR',
    'en': 'RESUME',
  },
  'home.stop': {
    'pt': 'STOP',
    'en': 'STOP',
  },
  'home.shiftInactive': {
    'pt': 'Este turno já não está activo.',
    'en': 'This shift is no longer active.',
  },
  'home.shiftUpdateError': {
    'pt': 'Não foi possível actualizar o turno.',
    'en': 'Could not update the shift.',
  },
  'home.pauseResumeError': {
    'pt': 'Erro PAUSA/RETOMAR. Tenta novamente.',
    'en': 'PAUSE/RESUME error. Try again.',
  },
  'home.stopError': {
    'pt': 'Erro STOP. Tenta novamente.',
    'en': 'STOP error. Try again.',
  },
  'login.createAccount': {
    'pt': 'Criar conta',
    'en': 'Create account',
  },
  'register.backToLogin': {
    'pt': 'Voltar para login',
    'en': 'Back to login',
  },
  'register.createAccount': {
    'pt': 'Criar conta',
    'en': 'Create account',
  },
  'shift.noActive': {
    'pt': 'Sem turno activo.',
    'en': 'No active shift.',
  },
  'shift.notAuthenticated': {
    'pt': 'Utilizador não autenticado.',
    'en': 'User not signed in.',
  },
  'shift.notOwner': {
    'pt': 'Turno não pertence a este utilizador.',
    'en': 'Shift does not belong to this user.',
  },
  'shift.pauseStarted': {
    'pt': 'Pausa iniciada.',
    'en': 'Break started.',
  },
  'shift.resumed': {
    'pt': 'Turno retomado.',
    'en': 'Shift resumed.',
  },
  'shift.pauseResumeFailed': {
    'pt': 'Erro ao pausar/retomar. Tenta novamente.',
    'en': 'Error pausing/resuming. Try again.',
  },
  'shift.stopped': {
    'pt': 'Turno terminado.',
    'en': 'Shift ended.',
  },
  'shift.stopFailed': {
    'pt': 'Erro ao terminar turno. Tenta novamente.',
    'en': 'Error ending shift. Try again.',
  },
  'history.weekly': {
    'pt': 'Últimos 7 dias',
    'en': 'Last 7 days',
  },
  'history.weekTotal': {
    'pt': 'Total da semana',
    'en': 'Week total',
  },
  'history.noShifts': {
    'pt': 'Sem turnos',
    'en': 'No shifts',
  },
  'history.shiftsCount': {
    'pt': 'turnos',
    'en': 'shifts',
  },
  'history.shiftCount': {
    'pt': 'turno',
    'en': 'shift',
  },
  'history.today': {
    'pt': 'Hoje',
    'en': 'Today',
  },
  'history.yesterday': {
    'pt': 'Ontem',
    'en': 'Yesterday',
  },
  'weekday.1': {'pt': 'Seg', 'en': 'Mon'},
  'weekday.2': {'pt': 'Ter', 'en': 'Tue'},
  'weekday.3': {'pt': 'Qua', 'en': 'Wed'},
  'weekday.4': {'pt': 'Qui', 'en': 'Thu'},
  'weekday.5': {'pt': 'Sex', 'en': 'Fri'},
  'weekday.6': {'pt': 'Sáb', 'en': 'Sat'},
  'weekday.7': {'pt': 'Dom', 'en': 'Sun'},
  'common.hoursShort': {'pt': 'h', 'en': 'h'},
  'common.minutesShort': {'pt': 'm', 'en': 'm'},
  'reports.title': {'pt': 'Relatórios', 'en': 'Reports'},
  'reports.filterToday': {'pt': 'Hoje', 'en': 'Today'},
  'reports.filterWeek': {'pt': 'Esta semana', 'en': 'This week'},
  'reports.filterMonth': {'pt': 'Este mês', 'en': 'This month'},
  'reports.filterCustom': {'pt': 'Personalizado', 'en': 'Custom'},
  'reports.exportPdf': {'pt': 'Exportar PDF', 'en': 'Export PDF'},
  'reports.generatingPdf': {'pt': 'A gerar PDF…', 'en': 'Generating PDF…'},
  'reports.totalPeriod': {'pt': 'Total no período', 'en': 'Total in period'},
  'reports.shifts': {'pt': 'Turnos', 'en': 'Shifts'},
  'reports.shiftsList': {'pt': 'Turnos no período', 'en': 'Shifts in period'},
  'reports.empty': {'pt': 'Sem turnos no período.', 'en': 'No shifts in period.'},
  'reports.startDate': {'pt': 'Data início', 'en': 'Start date'},
  'reports.endDate': {'pt': 'Data fim', 'en': 'End date'},
  'reports.inProgress': {'pt': 'Em curso', 'en': 'In progress'},
  'reports.completed': {'pt': 'Concluído', 'en': 'Completed'},
  'notif.nineHours.title': {
    'pt': 'Atingiste 9 horas de trabalho',
    'en': 'You have worked 9 hours',
  },
  'notif.nineHours.body': {
    'pt':
        'Já trabalhaste 9 horas hoje. Considera terminar o turno e descansar.',
    'en':
        'You have worked 9 hours today. Consider ending your shift and resting.',
  },
  'notif.endOfDay.title': {
    'pt': 'Não te esqueças de terminar o turno',
    'en': "Don't forget to end your shift",
  },
  'notif.endOfDay.body': {
    'pt': 'Lembrete: termina o teu turno antes de ir dormir.',
    'en': 'Reminder: end your shift before going to bed.',
  },

  // Homepage extra strings
  'home.welcome': {'pt': 'Bem-vindo', 'en': 'Welcome'},
  'home.hoursToday': {
    'pt': 'Horas Trabalhadas Hoje',
    'en': 'Hours Worked Today',
  },

  // Settings extra
  'settings.account': {'pt': 'Conta', 'en': 'Account'},
  'settings.driverData': {'pt': 'Dados do motorista', 'en': 'Driver data'},
  'settings.vehicleData': {'pt': 'Dados do veículo', 'en': 'Vehicle data'},

  // Driver / Vehicle forms
  'form.driverTitle': {'pt': 'Dados do Motorista', 'en': 'Driver Data'},
  'form.vehicleTitle': {'pt': 'Dados do Veículo', 'en': 'Vehicle Data'},

  'form.name': {'pt': 'Nome', 'en': 'Name'},
  'form.nameHint': {'pt': 'Introduz o teu nome', 'en': 'Enter your name'},

  'form.email': {'pt': 'Email', 'en': 'Email'},
  'form.emailHint': {'pt': 'Introduz o teu email', 'en': 'Enter your email'},

  'form.phone': {'pt': 'Telefone', 'en': 'Phone'},
  'form.phoneHint': {
    'pt': 'Introduz o teu telefone',
    'en': 'Enter your phone number',
  },

  'form.certificate': {
    'pt': 'Certificado de motorista',
    'en': 'Driver certificate',
  },
  'form.certificateHint': {
    'pt': 'Número do certificado',
    'en': 'Certificate number',
  },

  'form.nif': {'pt': 'NIF', 'en': 'Tax ID'},
  'form.nifHint': {'pt': 'Introduz o NIF', 'en': 'Enter Tax ID'},

  'form.plate': {'pt': 'Matrícula', 'en': 'Plate'},
  'form.plateHint': {'pt': 'Introduz a matrícula', 'en': 'Enter the plate'},

  'form.brand': {'pt': 'Marca', 'en': 'Brand'},
  'form.brandHint': {
    'pt': 'Introduz a marca do veículo',
    'en': 'Enter the vehicle brand',
  },

  'form.year': {'pt': 'Ano', 'en': 'Year'},
  'form.yearHint': {'pt': '2025', 'en': '2025'},

  'form.color': {'pt': 'Cor', 'en': 'Color'},
  'form.colorHint': {
    'pt': 'Introduz a cor do veículo',
    'en': 'Enter the vehicle color',
  },

  'form.operatorLicense': {
    'pt': 'Licença do Operador',
    'en': 'Operator License',
  },
  'form.operatorLicenseHint': {
    'pt': 'Introduz a licença do operador',
    'en': 'Enter the operator license',
  },

  'form.save': {'pt': 'Guardar', 'en': 'Save'},
  'form.mainMenu': {'pt': 'Menu principal', 'en': 'Main menu'},
  'form.saved': {'pt': 'Dados guardados.', 'en': 'Data saved.'},
  'form.saveError': {
    'pt': 'Erro ao guardar. Tenta novamente.',
    'en': 'Error saving. Try again.',
  },
  'settings.legal': {'pt': 'Legal', 'en': 'Legal'},
  'settings.privacy': {
    'pt': 'Politica de Privacidade',
    'en': 'Privacy Policy',
  },
  'settings.terms': {
    'pt': 'Termos de Utilizacao',
    'en': 'Terms of Use',
  },
  'legal.privacy.title': {
    'pt': 'Politica de Privacidade',
    'en': 'Privacy Policy',
  },
  'legal.privacy.body': {
    'pt':
        'A Drive Time trata os dados necessarios ao registo de turnos, pausas e relatorios TVDE. Os dados ficam associados a tua conta e sao usados apenas para o funcionamento da aplicacao. Podes pedir correcao ou eliminacao contactando o suporte. Nao vendemos dados pessoais a terceiros.',
    'en':
        'Drive Time processes data needed to register shifts, breaks, and TVDE reports. Data is linked to your account and used only to run the app. You may request correction or deletion by contacting support. We do not sell personal data to third parties.',
  },
  'legal.terms.title': {
    'pt': 'Termos de Utilizacao',
    'en': 'Terms of Use',
  },
  'legal.terms.body': {
    'pt':
        'A Drive Time e uma ferramenta de apoio ao registo de horas para motoristas TVDE. Os relatorios e totais sao informativos: deves validar sempre os registos e cumprir a legislacao aplicavel. O uso continuado da app implica aceitacao destes termos.',
    'en':
        'Drive Time is a support tool for logging hours for TVDE drivers. Reports and totals are informational: always verify records and comply with applicable law. Continued use of the app means you accept these terms.',
  },
  'validation.required': {
    'pt': 'Campo obrigatorio.',
    'en': 'Required field.',
  },
  'validation.email': {
    'pt': 'Email invalido.',
    'en': 'Invalid email.',
  },
  'validation.passwordMin': {
    'pt': 'Minimo 6 caracteres.',
    'en': 'At least 6 characters.',
  },
  'validation.passwordMatch': {
    'pt': 'As palavras-passe nao coincidem.',
    'en': 'Passwords do not match.',
  },
  'validation.nif': {
    'pt': 'NIF deve ter 9 digitos.',
    'en': 'Tax ID must have 9 digits.',
  },
  'validation.phone': {
    'pt': 'Telefone deve ter 9 digitos.',
    'en': 'Phone must have 9 digits.',
  },
  'validation.plate': {
    'pt': 'Matricula invalida (ex: AB-12-CD).',
    'en': 'Invalid plate (e.g. AB-12-CD).',
  },
  'validation.year': {
    'pt': 'Ano invalido.',
    'en': 'Invalid year.',
  },
  'shift.stopConfirmTitle': {
    'pt': 'Terminar turno?',
    'en': 'End shift?',
  },
  'shift.stopConfirmBody': {
    'pt': 'Queres mesmo terminar o turno actual?',
    'en': 'Do you really want to end the current shift?',
  },
  'common.cancel': {'pt': 'Cancelar', 'en': 'Cancel'},
  'common.confirm': {'pt': 'Confirmar', 'en': 'Confirm'},
};
