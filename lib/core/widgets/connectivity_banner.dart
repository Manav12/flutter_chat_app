// This widget show small "no internet" banner at bottom of screen when
// phone go offline.
import 'package:flutter/material.dart';

import '../network/network_info.dart';

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
        Expanded(child: child),
        StreamBuilder<bool>(
          stream: networkInfo.onConnectivityChanged,
          builder: (context, snapshot) {
            final isOffline = snapshot.data == false;
            return AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: isOffline
                  ? SafeArea(
                      top: false,
                      child: Container(
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
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}
