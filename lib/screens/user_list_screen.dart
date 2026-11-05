import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Latihan 4: kata kunci pencarian
  String _searchQuery = '';

  // Latihan 5: timeout (detik) yang bisa dipilih dari menu AppBar
  int _timeoutSeconds = 10;

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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.getUsers(
        timeout: Duration(seconds: _timeoutSeconds),
      );
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Latihan 4: filter berdasarkan nama atau email (tidak peka huruf besar/kecil)
  List<User> get _filteredUsers {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _users;
    return _users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Latihan 5: pilih timeout
          PopupMenuButton<int>(
            icon: const Icon(Icons.timer),
            tooltip: 'Atur timeout',
            initialValue: _timeoutSeconds,
            onSelected: (seconds) {
              setState(() => _timeoutSeconds = seconds);
              _loadUsers();
            },
            itemBuilder: (context) => [1, 5, 10, 30]
                .map(
                  (seconds) => PopupMenuItem<int>(
                    value: seconds,
                    child: Text('Timeout $seconds detik'),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_users.isEmpty) {
      return const Center(
        child: Text('Tidak ada data pengguna'),
      );
    }

    // Success state: kolom pencarian + daftar hasil
    final users = _filteredUsers;

    return Column(
      children: [
        // Latihan 4: kolom pencarian
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const Center(child: Text('Pengguna tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(
                        user: user,
                        onTap: () {
                          _showUserDetail(user);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showUserDetail(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Username: ${user.username}'),
            Text('Email: ${user.email}'),
            Text('Telepon: ${user.phone}'),
            Text('Website: ${user.website}'),
            Text('Perusahaan: ${user.companyName}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
