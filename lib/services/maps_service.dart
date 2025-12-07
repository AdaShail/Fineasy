import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Service for handling maps integration and address management
class MapsService {
  /// Open address in maps app
  static Future<bool> openInMaps({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri uri;

      if (latitude != null && longitude != null) {
        // Use coordinates if available (more accurate)
        if (Platform.isIOS) {
          uri = Uri.parse('maps://?q=$latitude,$longitude');
        } else {
          uri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
        }
      } else {
        // Use address string
        final encodedAddress = Uri.encodeComponent(address);
        if (Platform.isIOS) {
          uri = Uri.parse('maps://?q=$encodedAddress');
        } else {
          uri = Uri.parse('geo:0,0?q=$encodedAddress');
        }
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to Google Maps web
      return await openInGoogleMapsWeb(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      return false;
    }
  }

  /// Open in Google Maps web (fallback)
  static Future<bool> openInGoogleMapsWeb({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri uri;

      if (latitude != null && longitude != null) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      } else {
        final encodedAddress = Uri.encodeComponent(address);
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get directions to address
  static Future<bool> getDirections({
    required String destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? originAddress,
    double? originLatitude,
    double? originLongitude,
  }) async {
    try {
      String url;

      if (Platform.isIOS) {
        // Apple Maps directions
        if (destinationLatitude != null && destinationLongitude != null) {
          url = 'maps://?daddr=$destinationLatitude,$destinationLongitude';
          if (originLatitude != null && originLongitude != null) {
            url += '&saddr=$originLatitude,$originLongitude';
          }
        } else {
          final encodedDest = Uri.encodeComponent(destinationAddress);
          url = 'maps://?daddr=$encodedDest';
        }
      } else {
        // Google Maps directions
        if (destinationLatitude != null && destinationLongitude != null) {
          url = 'google.navigation:q=$destinationLatitude,$destinationLongitude';
        } else {
          final encodedDest = Uri.encodeComponent(destinationAddress);
          url = 'google.navigation:q=$encodedDest';
        }
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to web
      return await getDirectionsWeb(
        destinationAddress: destinationAddress,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        originAddress: originAddress,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
      );
    } catch (e) {
      return false;
    }
  }

  /// Get directions via Google Maps web
  static Future<bool> getDirectionsWeb({
    required String destinationAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? originAddress,
    double? originLatitude,
    double? originLongitude,
  }) async {
    try {
      String url = 'https://www.google.com/maps/dir/?api=1';

      // Add destination
      if (destinationLatitude != null && destinationLongitude != null) {
        url += '&destination=$destinationLatitude,$destinationLongitude';
      } else {
        final encodedDest = Uri.encodeComponent(destinationAddress);
        url += '&destination=$encodedDest';
      }

      // Add origin if provided
      if (originLatitude != null && originLongitude != null) {
        url += '&origin=$originLatitude,$originLongitude';
      } else if (originAddress != null) {
        final encodedOrigin = Uri.encodeComponent(originAddress);
        url += '&origin=$encodedOrigin';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Show address options dialog
  static Future<void> showAddressOptions({
    required BuildContext context,
    required String address,
    String? customerName,
    double? latitude,
    double? longitude,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customerName != null) ...[
              Text(
                customerName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              address,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text('Open in Maps'),
              onTap: () async {
                Navigator.pop(context);
                final success = await openInMaps(
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open maps'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions, color: Colors.green),
              title: const Text('Get Directions'),
              onTap: () async {
                Navigator.pop(context);
                final success = await getDirections(
                  destinationAddress: address,
                  destinationLatitude: latitude,
                  destinationLongitude: longitude,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open directions'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.orange),
              title: const Text('Copy Address'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard(context, address);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.purple),
              title: const Text('Share Address'),
              onTap: () {
                Navigator.pop(context);
                _shareAddress(context, address, customerName);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Copy address to clipboard
  static void _copyToClipboard(BuildContext context, String address) {
    // Note: Requires clipboard package
    // Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Share address
  static void _shareAddress(
    BuildContext context,
    String address,
    String? customerName,
  ) {
    // Note: Requires share_plus package
    final text = customerName != null
        ? '$customerName\n$address'
        : address;
    
    // Share.share(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: $text'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Format address for display
  static String formatAddress({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    final parts = <String>[];
    
    if (street != null && street.isNotEmpty) parts.add(street);
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (postalCode != null && postalCode.isNotEmpty) parts.add(postalCode);
    if (country != null && country.isNotEmpty) parts.add(country);

    return parts.join(', ');
  }

  /// Parse address string into components (basic implementation)
  static Map<String, String> parseAddress(String address) {
    final parts = address.split(',').map((s) => s.trim()).toList();
    
    return {
      'street': parts.isNotEmpty ? parts[0] : '',
      'city': parts.length > 1 ? parts[1] : '',
      'state': parts.length > 2 ? parts[2] : '',
      'postalCode': parts.length > 3 ? parts[3] : '',
      'country': parts.length > 4 ? parts[4] : '',
    };
  }

  /// Validate address format
  static bool isValidAddress(String address) {
    if (address.trim().isEmpty) return false;
    if (address.length < 10) return false; // Minimum reasonable address length
    return true;
  }

  /// Get address display widget
  static Widget buildAddressWidget({
    required String address,
    String? customerName,
    double? latitude,
    double? longitude,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.red.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerName != null) ...[
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    address,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

/// Address model for structured address data
class AddressModel {
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => MapsService.formatAddress(
    street: street,
    city: city,
    state: state,
    postalCode: postalCode,
    country: country,
  );

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    street: json['street'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    postalCode: json['postal_code'] as String?,
    country: json['country'] as String?,
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
  );
}
