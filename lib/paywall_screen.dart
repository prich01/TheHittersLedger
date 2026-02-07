import 'package:flutter/material.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upgrade to Pro Pass'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.stars_rounded, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Unlock Unlimited Access",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              "Free users are limited to 10 At-Bats. Upgrade to the Pro Pass for unlimited logs, season management, and advanced heat maps.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // Monthly Option
            _buildPriceCard(
              context,
              title: "Monthly Subscription",
              price: "\$2.99",
              interval: "per month",
              priceId: "1SyIgZRzEJzK6wa6lbzEnEpa", // PASTE YOUR MONTHLY STRIPE ID HERE
            ),
            
            const SizedBox(height: 15),
            
            // Yearly Option (Best Value)
            _buildPriceCard(
              context,
              title: "Annual Pro Pass",
              price: "\$19.99",
              interval: "per year",
              isBestValue: true,
              priceId: "price_1SyIlARzEJzK6wa6Ajcb7cnv", // PASTE YOUR YEARLY STRIPE ID HERE
            ),
            
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Maybe Later",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, {
    required String title, 
    required String price, 
    required String interval, 
    required String priceId,
    bool isBestValue = false
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: isBestValue ? Colors.blueAccent : Colors.grey.shade300, 
          width: isBestValue ? 2.5 : 1.0
        ),
        borderRadius: BorderRadius.circular(15),
        color: isBestValue ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: Column(
        children: [
          if (isBestValue)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text("BEST VALUE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("$price $interval", style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBestValue ? Colors.blueAccent : Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // Next step: Link this to your Stripe Checkout URL logic
                  print("User selected price ID: $priceId");
                },
                child: const Text("Select"),
              )
            ],
          ),
        ],
      ),
    );
  }
}