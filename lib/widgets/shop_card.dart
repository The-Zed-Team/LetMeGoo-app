import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/models/shop.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Could show a snackbar error here
    }
  }

  void _openMap(double latitude, double longitude) {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    _launchUrl(googleMapsUrl);
  }

  void _makePhoneCall(String phoneNumber) {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    _launchUrl(phoneUri);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child:
                shop.imageUrl != null
                    ? Image.network(
                      shop.imageUrl!,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.store,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                    : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        shop.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (shop.distance != null)
                      Text(
                        '${shop.distance!.toStringAsFixed(1)} km',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.schedule,
                  text: shop.operatingHours,
                  context: context,
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onPressed: () => _makePhoneCall(shop.phoneNumber),
                      context: context,
                    ),
                    _buildActionButton(
                      icon: Icons.directions_outlined,
                      label: 'Navigate',
                      onPressed: () => _openMap(shop.latitude, shop.longitude),
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return TextButton.icon(
      icon: Icon(icon, color: AppColors.primary),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
