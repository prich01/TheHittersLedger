import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html; // Add this line

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  /// This is the "Magic" function that triggers the Firebase Extension.
  /// It creates a document that the extension watches to generate a real Stripe URL.
  Future<void> _launchStripe(BuildContext context, String priceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to make a purchase.")),
      );
      return;
    }

    // 1. Show a loading indicator while we wait for the Extension to respond
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text("Preparing secure checkout..."),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 2. Add a document to the checkout_sessions sub-collection.
      // This includes the priceId and the URLs to return to after the purchase.
      final docRef = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('checkout_sessions')
          .add({
        'price': priceId,
        'success_url': '${html.window.location.origin}/app?status=success', 
  'cancel_url': '${html.window.location.origin}/app?status=cancel',
      });

      // 3. Listen for the extension to write back a 'url' or an 'error'
      docRef.snapshots().listen((snap) async {
        if (snap.exists) {
          final data = snap.data();
          final url = data?['url'];
          final error = data?['error'];

          if (error != null) {
            if (context.mounted) Navigator.pop(context); // Remove loader
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Stripe Error: ${error['message']}")),
            );
          } else if (url != null) {
            if (context.mounted) Navigator.pop(context); // Remove loader
            final Uri stripeUri = Uri.parse(url);
            await launchUrl(stripeUri, mode: LaunchMode.externalApplication);
          }
        }
      });
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Remove loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e")),
      );
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
                  "Free users are limited to 10 At-Bats. Upgrade for unlimited logs, season management, and advanced heat maps.",
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
                  // IMPORTANT: Ensure these Price IDs match your Stripe Dashboard exactly
                  priceId: "price_1T2j0lRzEJzK6wa6Rfkq9c1L", 
                ),

                const SizedBox(height: 16),

                // Yearly Option (Best Value)
                _buildPriceCard(
                  context,
                  title: "Annual Pro Pass",
                  price: "\$19.99",
                  interval: "per year",
                  isBestValue: true,
                  priceId: "price_1T2j17RzEJzK6wa6onBTQviw", 
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
                  const Text("BEST VALUE",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                Text("$price $interval",
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 16)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBestValue ? Colors.blueAccent : Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            // We now pass the priceId to the trigger function
            onPressed: () => _launchStripe(context, priceId),
            child: const Text("Select"),
          )
        ],
      ),
    );
  }
}