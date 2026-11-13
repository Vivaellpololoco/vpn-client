import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:hiddify/features/proxy/widget/proxy_tile.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// Nagorny Express home: the servers (flag, name, ping) right under the connect button, so a
/// country is picked and its ping seen without leaving the home page. The core lists them only
/// while it runs, so before connecting a hint stands in their place.
class HomeServerList extends HookConsumerWidget with PresLogger {
  const HomeServerList({super.key});

  static const _rowHeight = 72.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    if (!ref.watch(serviceRunningProvider)) {
      return SliverToBoxAdapter(child: _Hint(t.pages.proxies.connectToSeeProxies));
    }

    final proxies = ref.watch(proxiesOverviewNotifierProvider);
    return proxies.when(
      data: (group) {
        if (group == null) return const SliverToBoxAdapter(child: _Loading());
        final items = group.items.where((e) => !e.resting && e.tag != balanceGroupTag).toList();
        if (items.isEmpty) return SliverToBoxAdapter(child: _Hint(t.pages.proxies.empty));

        Future<void> testAll() async {
          try {
            await ref.read(proxiesOverviewNotifierProvider.notifier).urlTest(group.tag);
          } catch (e) {
            loggy.warning("ping test from home failed", e);
          }
        }

        return MultiSliver(
          children: [
            SliverToBoxAdapter(
              child: Padding(
                padding: _padding,
                child: Row(
                  children: [
                    Text(t.pages.proxies.title, style: theme.textTheme.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: testAll,
                      icon: const Icon(Icons.bolt_rounded),
                      label: Text(t.pages.proxies.testDelay),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(4)),
            SliverPadding(
              padding: _padding,
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final proxy = items[index];
                  return SizedBox(
                    height: _rowHeight,
                    child: ProxyTile(
                      proxy,
                      key: ValueKey(proxy.tag),
                      selected: group.selected == proxy.tag,
                      onTap: () =>
                          ref.read(proxiesOverviewNotifierProvider.notifier).changeProxy(group.tag, proxy.tag),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      error: (error, _) => SliverToBoxAdapter(
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(proxiesOverviewNotifierProvider),
            child: Text(t.connection.tapToRetry),
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: _Loading()),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}
