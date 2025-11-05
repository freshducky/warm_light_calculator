import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/services/calculation_history.dart';
import '../../core/services/iap_service.dart';
import '../../core/services/ad_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final bool isWarmTheme;
  final Function(ThemeMode, bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.isWarmTheme,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';
  final IAPService _iapService = IAPService();
  List<ProductDetails> _products = [];
  bool _isPurchasing = false;
  bool _adsRemoved = false;
  bool _isLoadingProducts = false;
  String? _iapError;
  bool _isPurchasingDonation = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _initializeIAP();
    _checkAdStatus();
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }

  Future<void> _initializeIAP() async {
    await _iapService.initialize();
    await _loadProducts();
  }

  Future<void> _checkAdStatus() async {
    final removed = await AdService.areAdsRemoved();
    if (mounted) {
      setState(() {
        _adsRemoved = removed;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _iapError = null;
    });

    try {
      final products = await _iapService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoadingProducts = false;
          if (products.isEmpty) {
            _iapError = 'Unable to load products. Please check your connection and try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _iapError = 'Error loading products: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _purchaseRemoveAds() async {
    if (_products.isEmpty) {
      await _loadProducts();
    }

    if (_products.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remove Ads product not available. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final removeAdsProduct = _products.firstWhere(
      (p) => p.id == 'remove.ads',
      orElse: () => _products.first,
    );

    if (removeAdsProduct.id != 'remove.ads') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remove Ads product not found. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isPurchasing = true;
      _iapError = null;
    });

    try {
      final success = await _iapService.purchaseRemoveAds(removeAdsProduct);
      
      if (!success && mounted) {
        setState(() {
          _iapError = 'Purchase could not be initiated. Please check your connection and try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Check status after purchase attempt (with delay to allow purchase to process)
      await Future.delayed(const Duration(seconds: 1));
      await _checkAdStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _iapError = 'Purchase error: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase error: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }
  
  Future<void> _purchaseDonation(ProductDetails product) async {
    setState(() {
      _isPurchasingDonation = true;
      _iapError = null;
    });

    try {
      final success = await _iapService.purchaseDonation(product);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your support!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation could not be processed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasingDonation = false;
        });
      }
    }
  }
  
  ProductDetails? _getDonationProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
      _iapError = null;
    });

    try {
      await _iapService.restorePurchases();
      await Future.delayed(const Duration(seconds: 1)); // Wait for restore to process
      await _checkAdStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_adsRemoved 
              ? 'Purchases restored successfully!' 
              : 'No purchases found to restore.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _iapError = 'Restore error: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Keep default values
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }
  
  Widget _buildDonationButton(BuildContext context, {required int tier, required String amount, required String productId}) {
    final product = _getDonationProduct(productId);
    final isAvailable = product != null;
    final isDisabled = _isPurchasingDonation || !isAvailable;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isDisabled ? null : () => _purchaseDonation(product!),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: isDisabled 
              ? Colors.grey.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        child: _isPurchasingDonation
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: isDisabled 
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isAvailable ? 'Support $amount' : '$amount (Unavailable)',
                  style: TextStyle(
                    color: isDisabled 
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all calculation history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentRed,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CalculationHistory.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  Future<void> _resetPreferences() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text(
          'Are you sure you want to reset all preferences? This will restore default settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentRed,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        widget.onThemeChanged(ThemeMode.light, false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferences reset')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reset preferences')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: widget.isWarmTheme
                        ? null
                        : (widget.currentThemeMode == ThemeMode.system
                            ? null
                            : widget.currentThemeMode),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onThemeChanged(value, false);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Warm Light'),
                    subtitle: const Text('Reduced blue light'),
                    value: ThemeMode.light,
                    groupValue: widget.isWarmTheme
                        ? (widget.currentThemeMode == ThemeMode.system
                            ? null
                            : widget.currentThemeMode)
                        : null,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onThemeChanged(value, true);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: widget.currentThemeMode == ThemeMode.system
                        ? null
                        : widget.currentThemeMode,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onThemeChanged(value, false);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Auto'),
                    subtitle: const Text('Follow system setting'),
                    value: ThemeMode.system,
                    groupValue: widget.currentThemeMode,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onThemeChanged(value, false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'App Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.apps),
                    title: const Text('Version'),
                    subtitle: Text('$_appVersion ($_buildNumber)'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl('https://www.myrentrange.com/privacy'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl('https://www.myrentrange.com/terms'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Feedback & Questions'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _openUrl('https://docs.google.com/forms/d/e/1FAIpQLSdDwllMZmCZvLQzw97gNQRoPswjwwcYXvzFCG69W69m8KfVkA/viewform'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.data_object),
                    title: const Text('Powered by Zillow Data'),
                    subtitle: const Text('Rent estimates use Zillow Home Value Index'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Support MyRentRange (IAP Donations)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Support MyRentRange',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MyRentRange is a solo project built to help renters understand fair housing costs and avoid overpaying. If this app helped you, please consider supporting it — every donation helps cover hosting, development, and research.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Donation Tiers
                  if (_isLoadingProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // $1 Donation
                    _buildDonationButton(
                      context,
                      tier: 1,
                      amount: '\$1',
                      productId: 'donation.tier.1',
                    ),
                    const SizedBox(height: 8),
                    // $5 Donation
                    _buildDonationButton(
                      context,
                      tier: 5,
                      amount: '\$5',
                      productId: 'donation.tier.5',
                    ),
                    const SizedBox(height: 8),
                    // $10 Donation
                    _buildDonationButton(
                      context,
                      tier: 10,
                      amount: '\$10',
                      productId: 'donation.tier.10',
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Thank you for helping make fair housing data more accessible!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2025 MyRentRange',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Remove Ads
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.block, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Remove Ads',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_adsRemoved) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ads Removed',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Remove banner ads with a one-time purchase of \$0.99. Support MyRentRange development!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_iapError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _iapError!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isPurchasing || _isLoadingProducts) ? null : _purchaseRemoveAds,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isPurchasing || _isLoadingProducts
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Remove Ads - \$0.99'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: (_isPurchasing || _isLoadingProducts) ? null : _restorePurchases,
                            child: const Text('Restore Purchases'),
                          ),
                        ),
                        if (_products.isEmpty || _iapError != null)
                          TextButton(
                            onPressed: _isLoadingProducts ? null : _loadProducts,
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storage, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Data Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear Calculation History'),
                    subtitle: const Text('Remove all saved calculations'),
                    onTap: _clearHistory,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Reset All Preferences'),
                    subtitle: const Text('Restore default settings'),
                    onTap: _resetPreferences,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

