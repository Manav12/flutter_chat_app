import 'package:flutter/material.dart';

import '../network/network_info.dart';

/// Wraps a screen and shows a thin "no internet" banner whenever we're
/// offline. It takes [networkInfo] as a parameter (instead of checking the
/// internet itself) so it's easy to test with a fake version.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.networkInfo,
    required this.child,
  });

  final NetworkInfo networkInfo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        StreamBuilder<bool>(
          stream: networkInfo.onConnectivityChanged,
          builder: (context, snapshot) {
            final isOffline = snapshot.data == false;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: isOffline
                  ? Container(
                      width: double.infinity,
                      color: colorScheme.errorContainer,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 16,
                            color: colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'No internet connection',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
        Expanded(child: child),
      ],
    );
  }
}
