import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/widgets/theme_toggle_widgets.dart';

/// A simplified home page that demonstrates light and dark theme support.
///
/// This page is a visual reference implementation based on the provided
/// screenshots. It intentionally keeps the logic minimal and focuses on
/// layout so it can be displayed without requiring any authentication.
class NewHomePage extends StatelessWidget {
  const NewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('oqdo'),
        centerTitle: true,
        actions: const [
          // Tapping this button toggles between light and dark themes.
          ThemeToggleButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section -------------------------------------------------
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/home.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Your world of Sports,\nHobbies and Wellness!',
                      style: textTheme.titleLarge!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('My Bookings'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category chips ----------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _CategoryChip(label: 'Sports', selected: true),
                _CategoryChip(label: 'Hobbies'),
                _CategoryChip(label: 'Wellness'),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions ------------------------------------------------
            Row(
              children: const [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.person_pin,
                    label: 'Book a Coach',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.location_city,
                    label: 'Book a Venue',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.meeting_room,
                    label: 'Hire Space',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Refer friends banner ---------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Invite friends to join our community and start earning',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Refer Now'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Community section -----------------------------------------
            Text('Community', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < _communityItems.length; i += 2)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i + 2 < _communityItems.length ? 12 : 0,
                          ),
                          child: _CommunityCard(item: _communityItems[i]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 1; i < _communityItems.length; i += 2)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i + 2 < _communityItems.length ? 12 : 0,
                          ),
                          child: _CommunityCard(item: _communityItems[i]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: selected ? colorScheme.primary : colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CommunityItem {
  const _CommunityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.item});

  final _CommunityItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitleStyle =
        textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6));

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(item.title,
                style: textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              style: subtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Community items used to build the two-column layout. The list order
/// places "Bazaar Sell" and "Bazaar Buy" in the right column.
final List<_CommunityItem> _communityItems = [
  const _CommunityItem(
    icon: Icons.people_alt_outlined,
    title: 'Find Friends',
    subtitle: 'Connect with like-minded people',
    iconColor: Colors.blue,
  ),
  const _CommunityItem(
    icon: Icons.sell_outlined,
    title: 'Bazaar Sell',
    subtitle: 'Sell your equipment',
    iconColor: Colors.purple,
  ),
  const _CommunityItem(
    icon: Icons.groups_outlined,
    title: 'Your Groups',
    subtitle: 'See your sports and hobby groups',
    iconColor: Colors.green,
  ),
  const _CommunityItem(
    icon: Icons.shopping_cart_outlined,
    title: 'Bazaar Buy',
    subtitle: 'Purchase equipment',
    iconColor: Colors.amber,
  ),
  const _CommunityItem(
    icon: Icons.event_available_outlined,
    title: 'Join Meetup',
    subtitle: 'See your meetup events',
    iconColor: Colors.orange,
  ),
];

