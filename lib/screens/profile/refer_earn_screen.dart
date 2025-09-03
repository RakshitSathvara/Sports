import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/screens/profile/intent/refer_earn_intent.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';

class ReferEarnScreen extends StatefulWidget {
  final ReferEarnIntent intent;

  const ReferEarnScreen({super.key, required this.intent});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  bool _isSharing = false; // Add this flag

  void _copyReferralCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.intent.referCode ?? ''));
    showSnackBarColor('Referral code copied to clipboard', context, false);
  }

  void _shareReferralCode() async {
    if (_isSharing) return; // Add this check

    setState(() {
      _isSharing = true;
    });

    final referCode = widget.intent.referCode ?? '';

    final message = """
I'm loving oqdo! 
You should give it a try too.
Sign up and use my code ($referCode) during registration.
Download the app here: https://oqdo.com/#download-app
    """;

    try {
      await Share.share(message, subject: 'My Referral Code');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share referral code')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Refer and Earn',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration
              Center(
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.asset('assets/images/ic_refer_earn.png'),
                ),
              ),
              const SizedBox(height: 24),
              // Refer and Earn Title
              const Text(
                'Refer and Earn',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF3A3A3A),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 24),
              // Steps
              _buildStep(1, 'Share your referral code'),
              _buildStep(2, 'Your friend registers with your code'),
              _buildStep(3, 'You earn rewards'),
              const SizedBox(height: 24),
              // Referral Code Container
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF006590).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.intent.referCode ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF006590),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _copyReferralCode(context),
                      child: Image.asset(
                        'assets/images/ic_copy.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _shareReferralCode,
                      child: Image.asset(
                        'assets/images/ic_share.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
              color: OQDOThemeData.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontFamily: 'Montserrat', color: OQDOThemeData.greyColor),
          ),
        ],
      ),
    );
  }
}
