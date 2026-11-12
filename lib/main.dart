import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const _projectId = 'flutter-appfirebase-1d948';
const _collection = 'usuario';
const _documentId = 'HhZquTJ4MmL64CLaAr2w';
const _ink = Color(0xFF172B4D);
const _muted = Color(0xFF718096);
const _canvas = Color(0xFFF5F7FA);
const _accent = Color(0xFF3977F6);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directorio de usuarios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: _accent),
        fontFamily: 'Roboto',
      ),
      home: const UserDirectoryScreen(),
    );
  }
}

class UserDirectoryScreen extends StatefulWidget {
  const UserDirectoryScreen({super.key});

  @override
  State<UserDirectoryScreen> createState() => _UserDirectoryScreenState();
}

class _UserDirectoryScreenState extends State<UserDirectoryScreen> {
  final _searchController = TextEditingController();
  List<Usuario> _usuarios = [];
  bool _loading = true;
  String? _error;
  DateTime? _lastUpdated;
  String _query = '';

  List<Usuario> get _filteredUsers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _usuarios;
    return _usuarios.where((user) {
      return user.nombre.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.numeroCuenta.toLowerCase().contains(query) ||
          user.id.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await FirestoreService.getUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = users;
        _loading = false;
        _lastUpdated = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                  sliver: SliverList.list(
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 30),
                      _buildHero(),
                      const SizedBox(height: 24),
                      _buildSummary(),
                      const SizedBox(height: 30),
                      _buildListHeader(),
                      const SizedBox(height: 16),
                      _buildContent(users),
                      const SizedBox(height: 26),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _softShadow,
          ),
          child: const Icon(Icons.grid_view_rounded, color: _accent, size: 22),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PANEL DE DATOS',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Firebase',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Actualizar datos',
          onPressed: _loading ? null : _loadUsers,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final connectionLabel = _loading
        ? 'CONECTANDO CON FIRESTORE'
        : _error == null
        ? 'FIRESTORE CONECTADO'
        : 'ERROR DE CONEXIÓN';
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF244B9B), Color(0xFF3977F6), Color(0xFF5B8EFF)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.23),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    SizedBox(width: 7),
                    Text(
                      connectionLabel,
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Personas,\nconectadas.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.06,
                  letterSpacing: -1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Consulta y encuentra los registros de tu colección usuario.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          );
          final icon = Container(
            width: compact ? 62 : 104,
            height: compact ? 62 : 104,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: compact ? 30 : 50,
              color: Colors.white,
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [icon, const SizedBox(height: 20), intro],
            );
          }
          return Row(
            children: [
              Expanded(child: intro),
              const SizedBox(width: 24),
              icon,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary() {
    final updated = _lastUpdated == null
        ? 'Esperando datos'
        : 'Actualizado ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final countCard = _statCard(
          Icons.people_outline_rounded,
          'Registros',
          '${_usuarios.length}',
          const Color(0xFF3977F6),
        );
        final sourceCard = _statCard(
          Icons.storage_rounded,
          'Origen',
          'Cloud Firestore',
          const Color(0xFF16A67A),
        );
        final updateCard = _statCard(
          Icons.schedule_rounded,
          'Sincronización',
          updated,
          const Color(0xFFF29A36),
        );
        if (compact) {
          return Column(
            children: [
              countCard,
              const SizedBox(height: 10),
              sourceCard,
              const SizedBox(height: 10),
              updateCard,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: countCard),
            const SizedBox(width: 12),
            Expanded(child: sourceCard),
            const SizedBox(width: 12),
            Expanded(child: updateCard),
          ],
        );
      },
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF3)),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = SizedBox(
          width: constraints.maxWidth < 620 ? double.infinity : 310,
          height: 48,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              hintStyle: const TextStyle(color: _muted, fontSize: 13),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: _muted,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5EAF1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5EAF1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _accent, width: 1.4),
              ),
            ),
          ),
        );
        final title = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Directorio',
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Registros guardados en Firestore',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        );
        if (constraints.maxWidth < 620)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 15), search],
          );
        return Row(
          children: [
            Expanded(child: title),
            search,
          ],
        );
      },
    );
  }

  Widget _buildContent(List<Usuario> users) {
    if (_loading) {
      return const _MessagePanel(
        icon: Icons.cloud_sync_rounded,
        title: 'Conectando con Firestore',
        message: 'Estamos cargando los registros…',
        loading: true,
      );
    }
    if (_error != null) {
      return _MessagePanel(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar los datos',
        message: _error!,
        action: FilledButton.icon(
          onPressed: _loadUsers,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      );
    }
    if (users.isEmpty) {
      return _MessagePanel(
        icon: _query.isEmpty
            ? Icons.person_search_rounded
            : Icons.search_off_rounded,
        title: _query.isEmpty ? 'Aún no hay registros' : 'Sin coincidencias',
        message: _query.isEmpty
            ? 'La colección usuario no contiene documentos visibles.'
            : 'Prueba con otro nombre, correo o número de cuenta.',
      );
    }
    return Column(
      children: [
        for (final user in users)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UserCard(user: user, onCopy: _copyText),
          ),
      ],
    );
  }

  Future<void> _copyText(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copiado'),
          behavior: SnackBarBehavior.floating,
          width: 250,
        ),
      );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined, size: 14, color: _muted),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Proyecto $_projectId  ·  colección $_collection',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onCopy});

  final Usuario user;
  final Future<void> Function(String text, String label) onCopy;

  @override
  Widget build(BuildContext context) {
    final initials = user.nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: _softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final identity = Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Cuenta ${user.numeroCuenta}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
          final email = _detail(
            Icons.mail_outline_rounded,
            user.email,
            () => onCopy(user.email, 'Correo'),
          );
          final id = _detail(
            Icons.fingerprint_rounded,
            user.id,
            () => onCopy(user.id, 'Identificador'),
          );
          if (compact)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 18),
                email,
                const SizedBox(height: 6),
                id,
              ],
            );
          return Row(
            children: [
              Expanded(flex: 4, child: identity),
              const SizedBox(width: 18),
              Expanded(flex: 4, child: email),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: id),
            ],
          );
        },
      ),
    );
  }

  Widget _detail(IconData icon, String value, VoidCallback copy) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _muted),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF43536B), fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: 'Copiar',
          visualDensity: VisualDensity.compact,
          onPressed: copy,
          icon: const Icon(Icons.content_copy_rounded, size: 15, color: _muted),
        ),
      ],
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        children: [
          if (loading)
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: _accent, size: 27),
            ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.numeroCuenta,
    required this.email,
  });

  final String id;
  final String nombre;
  final String numeroCuenta;
  final String email;

  factory Usuario.fromFirestoreRest(Map<String, dynamic> document) {
    final name = document['name'] as String? ?? '';
    final segments = name.split('/').where((part) => part.isNotEmpty).toList();
    final id = segments.isEmpty ? 'sin-id' : segments.last;
    final fields = document['fields'] as Map<String, dynamic>? ?? {};
    String value(List<String> keys, String fallback) {
      for (final key in keys) {
        final raw = fields[key];
        if (raw is! Map<String, dynamic>) continue;
        for (final type in [
          'stringValue',
          'integerValue',
          'doubleValue',
          'booleanValue',
        ]) {
          final candidate = raw[type];
          if (candidate != null && candidate.toString().trim().isNotEmpty)
            return candidate.toString();
        }
      }
      return fallback;
    }

    return Usuario(
      id: id,
      nombre: value(['nombre', 'name', 'nombreCompleto'], 'Usuario sin nombre'),
      numeroCuenta: value([
        'nocuenta',
        'noCuenta',
        'numeroCuenta',
        'cuenta',
      ], 'Sin número'),
      email: value(['email', 'correo', 'correoElectronico'], 'Sin correo'),
    );
  }
}

class FirestoreService {
  static Future<List<Usuario>> getUsuarios() async {
    final uri = Uri.https(
      'firestore.googleapis.com',
      '/v1/projects/$_projectId/databases/(default)/documents/$_collection/$_documentId',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      String? serverMessage;
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        serverMessage =
            (body['error'] as Map<String, dynamic>?)?['message'] as String?;
      } on FormatException {
        serverMessage = null;
      }
      if (response.statusCode == 403) {
        final detail = serverMessage == null ? '' : ' Detalle: $serverMessage';
        throw Exception(
          'Firestore denegó el acceso (403 PERMISSION_DENIED). Esta solicitud va sin iniciar sesión; configura autenticación y reglas de lectura para la colección usuario.$detail',
        );
      }
      throw Exception(
        'Firestore respondió con estado ${response.statusCode}. ${serverMessage ?? ''}',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return [Usuario.fromFirestoreRest(data)];
  }
}

const _softShadow = [
  BoxShadow(color: Color(0x0A172B4D), blurRadius: 18, offset: Offset(0, 5)),
];
