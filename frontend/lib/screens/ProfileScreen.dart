import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth/auth_service.dart';
import '../../services/card_service/card_service.dart';
import '../../dto/card_dto/UserInfoDto.dart';
import '../../dto/card_dto/card_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserInfoDto? user;
  List<CardModel> cards = [];
  int _loadedCardCount = 10;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadOwnedCards();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
        _loadMoreCards();
      }
    });
  }
  void _loadMoreCards() {
    if (_loadedCardCount >= cards.length) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _loadedCardCount = (_loadedCardCount + 10).clamp(0, cards.length);
        _isLoadingMore = false;
      });
    });
  }

  Future<void> _loadUserInfo() async {
    final loadedUser = await AuthService().loadUserInfo();
    setState(() => user = loadedUser);
  }

  Future<void> _loadOwnedCards() async {
    final fetchedCards = await CardService().fetchAllCards();
    setState(() => cards = fetchedCards);
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1.1, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          const Expanded(child: Divider(thickness: 1.1, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget buildDisabledInput({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: TextFormField(
                  initialValue: value,
                  enabled: false,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _navigateToCardDetails(CardModel card) {
    final extras = {'id': card.id.toString()};

    if (card.type == 'PHYSICAL') {
      context.push('/physical_card_details', extra: extras);
    } else {
      context.push('/virtual_card_details', extra: extras);
    }
  }

  Widget buildCardListSection() {
    final visibleCards = cards.take(_loadedCardCount).toList();

    return Column(
      children: [
        ...visibleCards.map((card) {
          return GestureDetector(
            onTap: () => _navigateToCardDetails(card),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ✅ Card Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${maskCardNumber(card.cardNumber)} — ${card.cardPack.label}',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.black,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.person, size: 14, color: Colors.black54),
                            const SizedBox(width: 5),
                            Text(
                              card.cardholderName ?? 'Unknown',
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(width: 10),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 10),
                            Text(
                              card.type,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(width: 10),
                            const Text('•', style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 10),
                            Text(
                              card.status,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: card.status.toLowerCase() == 'active'
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.destructiveRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.forward,
                      size: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CupertinoActivityIndicator(),
          ),
      ],
    );

  }

  String maskCardNumber(String? number) {
    if (number == null || number.length < 6) return '****';
    return '${number.substring(0, 6)}••••••${number.substring(number.length - 1)}';
  }
  Widget _buildCardTile(CardModel card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.35), Colors.white.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${maskCardNumber(card.cardNumber)} — ${card.cardPack.label}',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(CupertinoIcons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(card.cardholderName ?? 'Unknown', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    const SizedBox(width: 10),
                    const Text("•", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    Text(card.type, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(width: 10),
                    const Text("•", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    Text(
                      card.status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: card.status.toLowerCase() == 'active'
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.destructiveRed,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: CupertinoColors.systemGrey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F2FA), Color(0xFFEDEBFA), Color(0xFFFFF0F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/menu'),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    const Text('Profile',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600)),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.logout_rounded,
                          size: 20, color: CupertinoColors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: Image.asset('assets/profile.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 6),

                buildSectionTitle('Personal Information'),
                buildDisabledInput(
                    label: 'Username',
                    value: user!.username,
                    icon: Icons.person_outline),
                buildDisabledInput(
                    label: 'Birth Date',
                    value: '28/09/1999',
                    icon: Icons.calendar_today_outlined),

                buildSectionTitle('Account Information'),
                buildDisabledInput(
                    label: 'Email Address',
                    value: user!.email,
                    icon: Icons.email_outlined),
                buildDisabledInput(
                    label: 'Address',
                    value: '123 Rue Zerktouni, Casablanca',
                    icon: Icons.location_on_outlined),

                buildSectionTitle('Owned Cards'),
                buildCardListSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
