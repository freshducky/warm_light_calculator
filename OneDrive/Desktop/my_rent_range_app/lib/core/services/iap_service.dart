import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_service.dart';

/// Service for managing In-App Purchases
class IAPService {
  // Fixed product ID to match App Store Connect exactly
  static const String _removeAdsProductId = 'remove.ads';
  static const String _purchasedKey = 'iap_remove_ads_purchased';
  
  // Donation tier product IDs
  static const String _donationTier1ProductId = 'donation.tier.1';
  static const String _donationTier5ProductId = 'donation.tier.5';
  static const String _donationTier10ProductId = 'donation.tier.10';
  
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  /// Product details for all IAP products
  static const Set<String> _productIds = {
    _removeAdsProductId,
    _donationTier1ProductId,
    _donationTier5ProductId,
    _donationTier10ProductId,
  };
  
  /// Initialize IAP service
  Future<void> initialize() async {
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('IAP Service: Purchase stream error: $error');
      },
    );
  }
  
  /// Dispose IAP service
  void dispose() {
    _subscription?.cancel();
  }
  
  /// Get available products
  Future<List<ProductDetails>> getProducts() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        debugPrint('IAP Service: IAP not available on this device');
        return [];
      }
      
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      
      if (response.error != null) {
        debugPrint('IAP Service: Error querying products: ${response.error!.message}');
        debugPrint('IAP Service: Error code: ${response.error!.code}');
        debugPrint('IAP Service: Error details: ${response.error!.details}');
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP Service: Products not found: ${response.notFoundIDs}');
      }
      
      debugPrint('IAP Service: Found ${response.productDetails.length} products');
      return response.productDetails;
    } catch (e) {
      debugPrint('IAP Service: Exception getting products: $e');
      return [];
    }
  }
  
  /// Purchase "Remove Ads"
  Future<bool> purchaseRemoveAds(ProductDetails productDetails) async {
    try {
      debugPrint('IAP Service: Attempting to purchase Remove Ads: ${productDetails.id}');
      
      if (productDetails.id != _removeAdsProductId) {
        debugPrint('IAP Service: Error - Product ID mismatch. Expected: $_removeAdsProductId, Got: ${productDetails.id}');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      final bool result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('IAP Service: Purchase initiated: $result');
      return result;
    } catch (e) {
      debugPrint('IAP Service: Exception purchasing Remove Ads: $e');
      return false;
    }
  }
  
  /// Purchase donation tier
  Future<bool> purchaseDonation(ProductDetails productDetails) async {
    try {
      debugPrint('IAP Service: Attempting to purchase donation: ${productDetails.id}');
      
      // Validate product ID is a donation tier
      if (!_isDonationProduct(productDetails.id)) {
        debugPrint('IAP Service: Error - Invalid donation product ID: ${productDetails.id}');
        return false;
      }
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );
      
      // Donations are consumable (can be purchased multiple times)
      final bool result = await _iap.buyConsumable(purchaseParam: purchaseParam);
      debugPrint('IAP Service: Donation purchase initiated: $result');
      return result;
    } catch (e) {
      debugPrint('IAP Service: Exception purchasing donation: $e');
      return false;
    }
  }
  
  /// Check if product ID is a donation tier
  bool _isDonationProduct(String productId) {
    return productId == _donationTier1ProductId ||
           productId == _donationTier5ProductId ||
           productId == _donationTier10ProductId;
  }
  
  /// Get donation tier product IDs
  static List<String> getDonationProductIds() {
    return [
      _donationTier1ProductId,
      _donationTier5ProductId,
      _donationTier10ProductId,
    ];
  }
  
  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      debugPrint('IAP Service: Restoring purchases...');
      await _iap.restorePurchases();
      debugPrint('IAP Service: Restore purchases completed');
    } catch (e) {
      debugPrint('IAP Service: Exception restoring purchases: $e');
      rethrow;
    }
  }
  
  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('IAP Service: Purchase update - Product: ${purchaseDetails.productID}, Status: ${purchaseDetails.status}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('IAP Service: Purchase pending for ${purchaseDetails.productID}');
        // Purchase is pending - user is in the process of completing it
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('IAP Service: Purchase error for ${purchaseDetails.productID}');
        debugPrint('IAP Service: Error code: ${purchaseDetails.error?.code}');
        debugPrint('IAP Service: Error message: ${purchaseDetails.error?.message}');
        debugPrint('IAP Service: Error details: ${purchaseDetails.error?.details}');
        
        // Complete failed purchase to clear it from the queue
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        debugPrint('IAP Service: Purchase successful/restored for ${purchaseDetails.productID}');
        
        // Verify purchase and handle based on product type
        if (purchaseDetails.productID == _removeAdsProductId) {
          debugPrint('IAP Service: Activating Remove Ads');
          await AdService.setAdsRemoved(true);
          await _savePurchaseStatus(true);
        } else if (_isDonationProduct(purchaseDetails.productID)) {
          debugPrint('IAP Service: Donation received: ${purchaseDetails.productID}');
          // Donations don't unlock features, just acknowledge receipt
        }
        
        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchaseDetails);
            debugPrint('IAP Service: Purchase completed successfully');
          } catch (e) {
            debugPrint('IAP Service: Error completing purchase: $e');
          }
        }
      }
    }
  }
  
  /// Save purchase status
  Future<void> _savePurchaseStatus(bool purchased) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_purchasedKey, purchased);
      debugPrint('IAP Service: Purchase status saved: $purchased');
    } catch (e) {
      debugPrint('IAP Service: Error saving purchase status: $e');
    }
  }
  
  /// Check if Remove Ads was previously purchased
  Future<bool> hasPurchasedRemoveAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_purchasedKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}

