import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:invoice_maker/utils/app_localizations.dart';

class AppTool {
  static Future<void> shareApp(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    Share.share(
      '${AppLocalizations.of(context, 'download_share')} https://play.google.com/store/apps/details?id=$packageName',
    );
  }

  static Future<void> rateApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String packageName = packageInfo.packageName;
    // Gunakan market:// untuk membuka langsung di Play Store jika terinstall
    final Uri url = Uri.parse('market://details?id=$packageName');
    final Uri webUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(webUrl);
      }
    } catch (e) {
      // Fallback if something goes wrong
      await launchUrl(webUrl);
    }
  }
}
