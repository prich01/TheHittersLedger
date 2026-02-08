import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  // Helper method to launch Stripe URLs
  Future<void> _launchStripe(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        // LaunchMode.externalApplication is essential for Web to open a new tab
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening payment page: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upgrade to Pro Pass'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // 1. HITTER'S LEDGER LOGO
                Image.asset(
                  'assets/hl_logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.stars_rounded,
                    size: 100,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(height: 30),

                // 2. HEADLINE
                const Text(
                  "Purchase A Pro Pass",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),
                const Text(
                  "Free users are limited to 10 At-Bats. Upgrade to the Pro Pass for unlimited logs, season management, and advanced heat maps.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
                ),

                const SizedBox(height: 40),

                // Monthly Option
                _buildPriceCard(
                  context,
                  title: "Monthly Subscription",
                  price: "\$2.99",
                  interval: "per month",
                  priceId: "1SyIgZRzEJzK6wa6lbzEnEpa",
                  // PASTE YOUR MONTHLY STRIPE LINK BELOW
                  stripeUrl: "https://buy.stripe.com/test_7sY8wR0L43BR62LbjZ8EM00",
                ),

                const SizedBox(height: 16),

                // Yearly Option (Best Value)
                _buildPriceCard(
                  context,
                  title: "Annual Pro Pass",
                  price: "\$19.99",
                  interval: "per year",
                  isBestValue: true,
                  priceId: "price_1SyIlARzEJzK6wa6Ajcb7cnv",
                  // PASTE YOUR YEARLY STRIPE LINK BELOW
                  stripeUrl: "https://buy.stripe.com/test_cNifZj2Tca0f0Ir4VB8EM01",
                ),

                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Back to My Ledger",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context,
      {required String title,
      required String price,
      required String interval,
      required String priceId,
      required String stripeUrl,
      bool isBestValue = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
            color: isBestValue ? Colors.blueAccent : Colors.grey.shade300,
            width: isBestValue ? 2.5 : 1.0),
        borderRadius: BorderRadius.circular(15),
        color: isBestValue ? Colors.blue.withOpacity(0.05) : Colors.white,
        boxShadow: [
          if (isBestValue)
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          if (isBestValue)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("BEST VALUE",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text("$price $interval",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 16)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isBestValue ? Colors.blueAccent : Colors.black87,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _launchStripe(context, stripeUrl),
                child: const Text("Select",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }
}