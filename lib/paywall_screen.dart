import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html;

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  /// This function now simply redirects the user to your working Stripe Payment Link
  Future<void> _launchStripe(BuildContext context, String paymentUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to make a purchase.")),
      );
      return;
    }

    // We append the client_reference_id so the Firebase Extension knows who paid.
    // We also prefill the email for a smoother checkout experience.
    final String finalUrl = "$paymentUrl?client_reference_id=${user.uid}&prefilled_email=${Uri.encodeComponent(user.email ?? '')}";
    final Uri stripeUri = Uri.parse(finalUrl);

    try {
      if (await canLaunchUrl(stripeUri)) {
        await launchUrl(stripeUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open checkout link.';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
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
                const Icon(Icons.stars_rounded, size: 100, color: Colors.amber),
                const SizedBox(height: 30),
                const Text(
                  "Purchase A Pro Pass",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // --- MONTHLY OPTION ---
                _buildPriceCard(
                  context,
                  title: "Monthly Subscription",
                  price: "\$2.99",
                  interval: "per month",
                  // PASTE YOUR MONTHLY STRIPE LINK HERE
                  paymentUrl: "https://buy.stripe.com/7sY8wR0L43BR62LbjZ8EM00", 
                ),

                const SizedBox(height: 16),

                // --- YEARLY OPTION ---
                _buildPriceCard(
                  context,
                  title: "Annual Pro Pass",
                  price: "\$19.99",
                  interval: "per year",
                  isBestValue: true,
                  // PASTE YOUR YEARLY STRIPE LINK HERE
                  paymentUrl: "https://buy.stripe.com/cNifZj2Tca0f0Ir4VB8EM01", 
                ),

                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back to My Ledger", style: TextStyle(color: Colors.grey)),
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
      required String paymentUrl, // Updated parameter
      bool isBestValue = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
            color: isBestValue ? Colors.blueAccent : Colors.grey.shade300,
            width: isBestValue ? 2.5 : 1.0),
        borderRadius: BorderRadius.circular(15),
        color: isBestValue ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBestValue)
                  const Text("BEST VALUE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text("$price $interval", style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBestValue ? Colors.blueAccent : Colors.black87,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _launchStripe(context, paymentUrl), // Calls the new redirect function
            child: const Text("Select"),
          )
        ],
      ),
    );
  }
}