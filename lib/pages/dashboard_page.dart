import 'package:admin_panel/widgets/stock_card.dart';
import 'package:admin_panel/widgets/stock_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalProducts = 0;
  int available = 0;
  int limited = 0;
  int outOfStock = 0;

  bool loading = true;
  bool _fetchScheduled = false;

  @override
  void initState() {
    super.initState();
    fetchStockData();
    setupRealtime();
  }

  Future<void> fetchStockData() async {
    try {
      final supabase = AppConfig.supabase;

      final response = await supabase.from('products').select('quantity');

      int total = response.length;
      int availableCount = 0;
      int limitedCount = 0;
      int outCount = 0;

      for (var item in response) {
        final qty = (item['quantity'] ?? 0) as int;

        if (qty == 0) {
          outCount++;
        } else if (qty <= 10) {
          limitedCount++;
        } else {
          availableCount++;
        }
      }

      if (!mounted) return;

      setState(() {
        totalProducts = total;
        available = availableCount;
        limited = limitedCount;
        outOfStock = outCount;
        loading = false;
      });
    } catch (e) {
      debugPrint('Fetch stock error: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  void setupRealtime() {
    final supabase = AppConfig.supabase;

    final channel = supabase.channel('products-dashboard');

    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'products'),
      (payload, [_]) {
        if (_fetchScheduled) return;

        _fetchScheduled = true;
        Future.delayed(const Duration(milliseconds: 120), () {
          _fetchScheduled = false;
          fetchStockData();
        });
      },
    ).subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: StockCard(
                            label: 'Total Products',
                            count: totalProducts,
                            color: Colors.blueGrey.shade800,
                            icon: Icons.inventory_2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StockCard(
                            label: 'Available',
                            count: available,
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StockCard(
                            label: 'Limited Stock',
                            count: limited,
                            color: Colors.orange,
                            icon: Icons.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StockCard(
                            label: 'Out of Stock',
                            count: outOfStock,
                            color: Colors.red,
                            icon: Icons.cancel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stock Distribution',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: StockPieChart(
                                available: available,
                                limited: limited,
                                outOfStock: outOfStock,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
