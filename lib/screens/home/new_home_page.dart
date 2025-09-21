import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/home/tools_card_view.dart';

class NewHomePage extends StatelessWidget {
  const NewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _firstSection(context),
            const SizedBox(height: 10),
            _secondSection(),
            const SizedBox(height: 10),
            _getTools(context),
            
            
    

            // Community section -----------------------------------------
            Text('Community', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Column
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _CommunityTile(
                            icon: Icons.person_search,
                            label: "Find Friends",
                            onTap: () {},
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _CommunityTile(
                            icon: Icons.group,
                            label: "Your Groups",
                            onTap: () {},
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _CommunityTile(
                            icon: Icons.event,
                            label: "Join Meetup",
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  // Bazaar Column
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _CommunityTile(
                            icon: Icons.sell,
                            label: "Bazaar Sell",
                            onTap: () {},
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _CommunityTile(
                            icon: Icons.shopping_basket,
                            label: "Bazaar Buy",
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _firstSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/new_home_page.jpg'), // Replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your world of Sports, Hobbies\nand Wellness!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Book a coach or a venue, organise sporting activities & hobbies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'My Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Image.asset('assets/images/new_home_sport.png',height: 80)),
        Flexible(child: Image.asset('assets/images/new_home_hobbies.png',height: 80)),
        Flexible(child: Image.asset('assets/images/new_home_wellness.png',height: 80))
      ],
    );
  }

  Widget _getTools(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coach Tools',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: [
              ToolsCard(
                title: 'Create Batch',
                subtitle: 'Coaching schedule',
                icon: Icons.check,
                iconColor: Colors.white,
                backgroundColor: Colors.green.shade100,
                circleColor: Colors.green.shade300,
                onTap: () => _handleCreateBatch(context),
              ),
              ToolsCard(
                title: 'Appointments',
                subtitle: "Today's sessions",
                icon: Icons.calendar_today,
                iconColor: Colors.white,
                backgroundColor: Colors.orange.shade50,
                circleColor: Colors.orange.shade300,
                onTap: () => _handleAppointments(context),
              ),
              ToolsCard(
                title: 'Set Vacation',
                subtitle: 'Block time off',
                icon: Icons.flight,
                iconColor: Colors.white,
                backgroundColor: Colors.blue.shade50,
                circleColor: Colors.blue.shade300,
                onTap: () => _handleSetVacation(context),
              ),
              ToolsCard(
                title: 'Cancellations',
                subtitle: 'Review requests',
                icon: Icons.cancel,
                iconColor: Colors.white,
                backgroundColor: Colors.red.shade50,
                circleColor: Colors.red.shade300,
                onTap: () => _handleCancellations(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCreateBatch(BuildContext context) {
    print('Create Batch tapped');
    // Navigate to create batch screen
  }

  void _handleAppointments(BuildContext context) {
    print('Appointments tapped');
    // Navigate to appointments screen
  }

  void _handleSetVacation(BuildContext context) {
    print('Set Vacation tapped');
    // Navigate to vacation settings
  }

  void _handleCancellations(BuildContext context) {
    print('Cancellations tapped');
    // Navigate to cancellations screen
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
    final subtitleStyle = textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6));

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
            Text(item.title, style: textTheme.titleMedium, textAlign: TextAlign.center),
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

class _CommunityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
