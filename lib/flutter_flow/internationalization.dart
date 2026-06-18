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
  'home.noActiveShift': {
    'pt': 'Sem turno activo. Inicia um turno quando estiveres pronto.',
    'en': 'No active shift. Start a shift when you are ready.',
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
    'pt': 'Voltar ao inicio de sessao',
    'en': 'Back to sign in',
  },
  'register.createAccount': {
    'pt': 'Criar conta',
    'en': 'Create account',
  },
  'register.confirmPassword': {
    'pt': 'Confirmar palavra-passe',
    'en': 'Confirm password',
  },
  'register.confirmPasswordHint': {
    'pt': 'Repete a palavra-passe',
    'en': 'Re-enter your password',
  },
  'register.fullName': {'pt': 'Nome', 'en': 'Full name'},
  'register.fullNameHint': {
    'pt': 'Nome completo',
    'en': 'Full legal name',
  },
  'register.mobile': {'pt': 'Telemovel', 'en': 'Mobile phone'},
  'register.mobileHint': {
    'pt': 'Numero de telemovel',
    'en': 'Your mobile number',
  },
  'register.cmtvde': {
    'pt': 'Certificado CMTVDE',
    'en': 'CMTVDE certificate',
  },
  'register.cmtvdeHint': {
    'pt': 'Numero do certificado CMTVDE',
    'en': 'CMTVDE certificate number',
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
  'history.emptyList': {
    'pt': 'Ainda não há turnos registados neste período.',
    'en': 'No shifts recorded in this period yet.',
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
    'pt': 'Política de Privacidade',
    'en': 'Privacy Policy',
  },
  'settings.terms': {
    'pt': 'Termos de Utilização',
    'en': 'Terms of Use',
  },
  'legal.privacy.title': {
    'pt': 'Política de Privacidade',
    'en': 'Privacy Policy',
  },
  'legal.privacy.body': {
    'pt':
        'Última atualização: março de 2026.\n\n'
        '1. Responsável pelo tratamento\n'
        'A Drive Time é uma aplicação de apoio ao registo de turnos, pausas e relatórios para motoristas TVDE. O responsável pelo tratamento dos dados pessoais é o titular da conta de utilizador da aplicação.\n\n'
        '2. Dados que tratamos\n'
        'Tratamos apenas os dados necessários ao funcionamento da app: email de autenticação, dados de motorista (nome, NIF, telefone, certificado CMTVDE), dados de veículo (matrícula, licença de operador), registos de turnos e pausas, e preferências da app (idioma e tema).\n\n'
        '3. Finalidade e base legal\n'
        'Os dados são usados exclusivamente para permitir o registo de horas, geração de relatórios e gestão da conta, com base na execução do contrato de utilização e no cumprimento de obrigações legais aplicáveis (incluindo o RGPD — Regulamento UE 2016/679).\n\n'
        '4. Não partilhamos os teus dados pessoais\n'
        'Não vendemos, alugamos nem partilhamos os teus dados pessoais com terceiros para fins comerciais ou de marketing. Os dados ficam associados à tua conta e são acessíveis apenas por ti, através de autenticação segura.\n\n'
        '5. Segurança e confidencialidade\n'
        'Os dados são armazenados em infraestrutura Firebase/Google Cloud, com comunicação encriptada (HTTPS/TLS) e regras de acesso que limitam a leitura e escrita ao utilizador autenticado titular dos registos. Empregamos medidas técnicas e organizativas adequadas para proteger a confidencialidade, integridade e disponibilidade dos dados.\n\n'
        '6. Subcontratantes\n'
        'Utilizamos serviços Google/Firebase (autenticação e base de dados) como subcontratantes de infraestrutura, sujeitos às respetivas políticas de privacidade e acordos de proteção de dados.\n\n'
        '7. Os teus direitos\n'
        'Nos termos do RGPD, podes solicitar acesso, retificação, eliminação, limitação do tratamento, portabilidade e oposição, contactando-nos em admin@drivetimeapp.com. Podes também apresentar reclamação à CNPD (Comissão Nacional de Proteção de Dados).\n\n'
        '8. Conservação\n'
        'Conservamos os dados enquanto a conta estiver ativa e pelo tempo necessário ao cumprimento de obrigações legais. Podes pedir a eliminação da conta e dos dados associados.\n\n'
        '9. Menores\n'
        'A aplicação destina-se a motoristas profissionais e não se dirige a menores de 16 anos.\n\n'
        '10. Alterações\n'
        'Podemos atualizar esta política. A versão em vigor está sempre disponível nesta página da app.',
    'en':
        'Last updated: March 2026.\n\n'
        '1. Data controller\n'
        'Drive Time is a support app for logging shifts, breaks, and reports for TVDE drivers. The data controller is the account holder using the application.\n\n'
        '2. Data we process\n'
        'We process only data required to run the app: authentication email, driver details (name, tax ID, phone, CMTVDE certificate), vehicle details (plate, operator licence), shift and break records, and app preferences (language and theme).\n\n'
        '3. Purpose and legal basis\n'
        'Data is used solely to enable hour logging, report generation, and account management, based on contract performance and applicable legal obligations (including GDPR — EU Regulation 2016/679).\n\n'
        '4. We do not share your personal data\n'
        'We do not sell, rent, or share your personal data with third parties for commercial or marketing purposes. Data is linked to your account and accessible only by you through secure authentication.\n\n'
        '5. Security and confidentiality\n'
        'Data is stored on Firebase/Google Cloud infrastructure with encrypted communication (HTTPS/TLS) and access rules that restrict read/write to the authenticated account owner. We apply appropriate technical and organisational measures to protect confidentiality, integrity, and availability.\n\n'
        '6. Processors\n'
        'We use Google/Firebase services (authentication and database) as infrastructure processors, subject to their privacy policies and data protection agreements.\n\n'
        '7. Your rights\n'
        'Under GDPR, you may request access, rectification, erasure, restriction, portability, and objection by contacting us at admin@drivetimeapp.com. You may also lodge a complaint with your national data protection authority.\n\n'
        '8. Retention\n'
        'We retain data while the account is active and as required by law. You may request account and data deletion.\n\n'
        '9. Minors\n'
        'The app is intended for professional drivers and is not directed at children under 16.\n\n'
        '10. Changes\n'
        'We may update this policy. The current version is always available on this in-app page.',
  },
  'legal.terms.title': {
    'pt': 'Termos de Utilização',
    'en': 'Terms of Use',
  },
  'legal.terms.body': {
    'pt':
        'Última atualização: março de 2026.\n\n'
        '1. Objeto\n'
        'A Drive Time é uma ferramenta de apoio ao registo de horas de trabalho, pausas e relatórios para motoristas de TVDE. Os totais e relatórios gerados são informativos: deves validar sempre os registos e cumprir a legislação aplicável.\n\n'
        '2. Utilização da app\n'
        'Comprometes-te a usar a aplicação de forma lícita, com dados verdadeiros e responsabilidade profissional. És responsável pela exatidão dos registos introduzidos.\n\n'
        '3. Limitação de responsabilidade\n'
        'A app não substitui aconselhamento jurídico, contabilístico ou laboral. A Drive Time não garante conformidade automática com todas as obrigações legais do motorista ou da plataforma TVDE.\n\n'
        '4. Legislação aplicável — Lei n.º 45/2018, de 10 de agosto\n'
        'Artigo 13.º — Duração da atividade\n'
        '1 — Os motoristas de TVDE não podem operar veículos de TVDE por mais de dez horas dentro de um período de 24 horas, independentemente do número de plataformas nas quais o motorista de TVDE preste serviços, sem prejuízo da aplicação das normas imperativas, nomeadamente do Código do Trabalho, se estabelecerem período inferior.\n\n'
        'A app pode emitir alertas informativos (por exemplo, após 9 horas de trabalho efectivo), mas a responsabilidade pelo cumprimento dos limites legais é sempre do motorista.\n\n'
        '5. Conta e segurança\n'
        'Deves manter as credenciais de acesso confidenciais. Notifica-nos em admin@drivetimeapp.com se suspeitares de uso não autorizado da tua conta.\n\n'
        '6. Aceitação\n'
        'O uso continuado da aplicação implica aceitação destes Termos de Utilização e da Política de Privacidade.',
    'en':
        'Last updated: March 2026.\n\n'
        '1. Purpose\n'
        'Drive Time is a support tool for logging working hours, breaks, and reports for TVDE drivers. Generated totals and reports are informational: always verify records and comply with applicable law.\n\n'
        '2. Use of the app\n'
        'You agree to use the app lawfully, with accurate data and professional responsibility. You are responsible for the accuracy of entered records.\n\n'
        '3. Limitation of liability\n'
        'The app does not replace legal, accounting, or labour advice. Drive Time does not guarantee automatic compliance with all driver or TVDE platform legal obligations.\n\n'
        '4. Applicable law — Law No. 45/2018, of 10 August (Portugal)\n'
        'Article 13 — Duration of activity\n'
        '1 — TVDE drivers may not operate TVDE vehicles for more than ten hours within a 24-hour period, regardless of the number of platforms on which the TVDE driver provides services, without prejudice to mandatory rules, namely the Labour Code, if they establish a shorter period.\n\n'
        'The app may issue informational alerts (for example, after 9 hours of effective work), but the driver is always responsible for complying with legal limits.\n\n'
        '5. Account and security\n'
        'Keep your login credentials confidential. Notify us at admin@drivetimeapp.com if you suspect unauthorised use of your account.\n\n'
        '6. Acceptance\n'
        'Continued use of the application means you accept these Terms of Use and the Privacy Policy.',
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
  'auth.email': {'pt': 'Email', 'en': 'Email'},
  'auth.password': {'pt': 'Palavra-passe', 'en': 'Password'},
  'auth.emailHint': {
    'pt': 'Introduz o teu email',
    'en': 'Enter your email',
  },
  'auth.passwordHint': {
    'pt': 'Introduz a palavra-passe',
    'en': 'Enter your password',
  },
  'auth.signIn': {'pt': 'Entrar', 'en': 'Sign in'},
  'auth.forgotPassword': {
    'pt': 'Esqueceste a palavra-passe?',
    'en': 'Forgot your password?',
  },
  'auth.enterEmailForReset': {
    'pt': 'Introduz o email para recuperar a palavra-passe.',
    'en': 'Enter your email to reset your password.',
  },
  'auth.resetPasswordSent': {
    'pt': 'Email de recuperacao enviado. Verifica a caixa de entrada.',
    'en': 'Password reset email sent. Check your inbox.',
  },
  'auth.resetPasswordError': {
    'pt': 'Nao foi possivel enviar o email de recuperacao.',
    'en': 'Could not send password reset email.',
  },
  'onboarding.completeProfile': {
    'pt': 'Completa os dados do motorista e do veiculo em Definicoes.',
    'en': 'Complete driver and vehicle data in Settings.',
  },
  'onboarding.missingDriverTitle': {
    'pt': 'Configura o teu perfil',
    'en': 'Set up your profile',
  },
  'onboarding.missingDriverBody': {
    'pt':
        'A tua conta ainda nao tem dados de motorista. Preenche o formulario para continuar.',
    'en':
        'Your account has no driver profile yet. Fill in the form to continue.',
  },
  'onboarding.setupProfile': {
    'pt': 'Preencher dados do motorista',
    'en': 'Fill in driver data',
  },
  'errors.generic': {
    'pt': 'Ocorreu um erro. Tenta novamente.',
    'en': 'Something went wrong. Please try again.',
  },
  'errors.network': {
    'pt': 'Sem ligacao a internet. Verifica a rede.',
    'en': 'No internet connection. Check your network.',
  },
  'errors.auth.generic': {
    'pt': 'Nao foi possivel concluir o inicio de sessao.',
    'en': 'Could not complete sign in.',
  },
  'errors.auth.emailInUse': {
    'pt': 'Este email ja esta registado.',
    'en': 'This email is already registered.',
  },
  'errors.auth.invalidEmail': {
    'pt': 'Email invalido.',
    'en': 'Invalid email address.',
  },
  'errors.auth.weakPassword': {
    'pt': 'Palavra-passe demasiado fraca (minimo 6 caracteres).',
    'en': 'Password is too weak (at least 6 characters).',
  },
  'errors.auth.invalidCredentials': {
    'pt': 'Email ou palavra-passe incorretos.',
    'en': 'Incorrect email or password.',
  },
  'errors.auth.tooManyRequests': {
    'pt': 'Demasiadas tentativas. Aguarda um momento.',
    'en': 'Too many attempts. Please wait a moment.',
  },
  'errors.auth.requiresRecentLogin': {
    'pt': 'Por seguranca, inicia sessao novamente.',
    'en': 'For security, please sign in again.',
  },
  'errors.firestore.permissionDenied': {
    'pt':
        'Sem permissao para aceder aos dados. Confirma que iniciaste sessao com a conta correta.',
    'en':
        'Permission denied. Make sure you are signed in with the correct account.',
  },
  'errors.firestore.unavailable': {
    'pt': 'Servico temporariamente indisponivel. Tenta mais tarde.',
    'en': 'Service temporarily unavailable. Try again later.',
  },
  'errors.firestore.failedPrecondition': {
    'pt': 'Operacao nao permitida neste momento.',
    'en': 'Operation not allowed right now.',
  },
  'reports.pdfError': {
    'pt': 'Nao foi possivel gerar o PDF. Tenta novamente.',
    'en': 'Could not generate the PDF. Please try again.',
  },
  'settings.appVersion': {
    'pt': 'Versao',
    'en': 'Version',
  },
  'settings.signOut': {'pt': 'Terminar sessão', 'en': 'Sign out'},
  'history.loadError': {
    'pt': 'Nao foi possivel carregar o historico.',
    'en': 'Could not load history.',
  },
};
