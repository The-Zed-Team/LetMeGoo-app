import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/providers/report_providers.dart';
import 'package:letmegoo/services/auth_service.dart';
import '../widgets/buildreportsection.dart';
import '../widgets/builddivider.dart';

class HomePage extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onAddPressed;

  const HomePage({super.key, this.onNavigate, this.onAddPressed});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportsIfNeeded();
    });
  }

  Future<void> _loadReportsIfNeeded() async {
    try {
      final cache = ref.read(reportsCacheProvider.notifier);
      final reportsNotifier = ref.read(reportsProvider.notifier);
      final currentState = ref.read(reportsProvider);
      print('🧪 DEBUG: Testing direct API call');
      final allReports = await AuthService.getAllReportsDebug();
      print('🧪 DEBUG: Got ${allReports.length} total reports');
      print('🔍 Loading reports check:');
      print('  - Cache valid: ${cache.isCacheValid}');
      print('  - Total reports: ${currentState.totalReports}');
      print('  - Is loading: ${currentState.isLoading}');
      print('  - Has error: ${currentState.error != null}');

      if (!cache.isCacheValid || currentState.totalReports == 0) {
        print('📥 Starting to load reports...');
        reportsNotifier
            .loadReports()
            .then((_) {
              if (mounted) {
                cache.updateCacheTime();
                final newState = ref.read(reportsProvider);
                print('✅ Reports loaded successfully:');
                print('  - Live by user: ${newState.liveByUser.length}');
                print(
                  '  - Live against user: ${newState.liveAgainstUser.length}',
                );
                print('  - Solved by user: ${newState.solvedByUser.length}');
                print(
                  '  - Solved against user: ${newState.solvedAgainstUser.length}',
                );
              }
            })
            .catchError((error) {
              print('❌ Error loading reports: $error');
              if (mounted) {
                _showErrorSnackBar('Failed to load reports. Please try again.');
              }
            });
      } else {
        print('✅ Using cached reports');
      }
    } catch (e) {
      print('❌ Exception in _loadReportsIfNeeded: $e');
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred.');
      }
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      print('🔄 Refreshing reports...');
      final reportsNotifier = ref.read(reportsProvider.notifier);
      final cache = ref.read(reportsCacheProvider.notifier);

      await reportsNotifier.refresh();
      if (mounted) {
        cache.updateCacheTime();
        final newState = ref.read(reportsProvider);
        print('✅ Reports refreshed:');
        print('  - Total: ${newState.totalReports}');
        _showSuccessSnackBar('Reports refreshed successfully');
      }
    } catch (e) {
      print('❌ Error refreshing: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to refresh reports. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _loadReportsIfNeeded(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _retryLoadingReports() {
    ref.read(reportsProvider.notifier).clearError();
    _loadReportsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, // Changed to white
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Reports', style: AppFonts.semiBold20()),
        centerTitle: true,
        // Removed all actions (refresh and debug buttons)
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: SafeArea(
          child: Column(
            children: [
              // Error banner
              Consumer(
                builder: (context, ref, child) {
                  final reportsState = ref.watch(reportsProvider);
                  if (reportsState.error != null &&
                      reportsState.error!.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reportsState.error!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _retryLoadingReports,
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Main Content
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final reportsState = ref.watch(reportsProvider);

                    print('🎨 Building UI with state:');
                    print('  - Loading: ${reportsState.isLoading}');
                    print('  - Has no reports: ${reportsState.hasNoReports}');
                    print('  - Error: ${reportsState.error}');

                    // Debug the formatted providers
                    late List<Map<String, dynamic>> liveByUserFormatted;
                    late List<Map<String, dynamic>> liveAgainstUserFormatted;
                    late List<Map<String, dynamic>> solvedByUserFormatted;
                    late List<Map<String, dynamic>> solvedAgainstUserFormatted;

                    try {
                      liveByUserFormatted = ref.watch(
                        liveReportsByUserFormattedProvider,
                      );
                      print(
                        '  - Live by user formatted: ${liveByUserFormatted.length}',
                      );
                    } catch (e) {
                      print('  - Error in liveByUserFormatted: $e');
                      liveByUserFormatted = [];
                    }

                    try {
                      liveAgainstUserFormatted = ref.watch(
                        liveReportsAgainstUserFormattedProvider,
                      );
                      print(
                        '  - Live against user formatted: ${liveAgainstUserFormatted.length}',
                      );
                    } catch (e) {
                      print('  - Error in liveAgainstUserFormatted: $e');
                      liveAgainstUserFormatted = [];
                    }

                    try {
                      solvedByUserFormatted = ref.watch(
                        solvedReportsByUserFormattedProvider,
                      );
                      print(
                        '  - Solved by user formatted: ${solvedByUserFormatted.length}',
                      );
                    } catch (e) {
                      print('  - Error in solvedByUserFormatted: $e');
                      solvedByUserFormatted = [];
                    }

                    try {
                      solvedAgainstUserFormatted = ref.watch(
                        solvedReportsAgainstUserFormattedProvider,
                      );
                      print(
                        '  - Solved against user formatted: ${solvedAgainstUserFormatted.length}',
                      );
                    } catch (e) {
                      print('  - Error in solvedAgainstUserFormatted: $e');
                      solvedAgainstUserFormatted = [];
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: const Color(0xFF31C5F4),
                      backgroundColor: Colors.white,
                      strokeWidth: 2.0,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isLargeScreen ? 900 : double.infinity,
                            minHeight: screenHeight * 0.7,
                          ),
                          child: Builder(
                            builder: (context) {
                              // Show loading state
                              if (reportsState.isLoading &&
                                  reportsState.hasNoReports) {
                                print('🔄 Showing loading widget');
                                return _LoadingWidget(
                                  screenHeight: screenHeight,
                                );
                              }

                              // Show error state
                              if (reportsState.error != null &&
                                  reportsState.hasNoReports &&
                                  !reportsState.isLoading) {
                                print('❌ Showing error widget');
                                return _ErrorWidget(
                                  screenHeight: screenHeight,
                                  errorMessage: reportsState.error!,
                                  onRetry: _retryLoadingReports,
                                );
                              }

                              // Show empty state
                              if (reportsState.hasNoReports &&
                                  !reportsState.isLoading) {
                                print('📭 Showing empty widget');
                                return _EmptyWidget(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  onRefresh: _onRefresh,
                                );
                              }

                              // Show content
                              print('📊 Showing reports content');
                              return _ReportsContent(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                isTablet: isTablet,
                                isLargeScreen: isLargeScreen,
                                liveByUserFormatted: liveByUserFormatted,
                                liveAgainstUserFormatted:
                                    liveAgainstUserFormatted,
                                solvedByUserFormatted: solvedByUserFormatted,
                                solvedAgainstUserFormatted:
                                    solvedAgainstUserFormatted,
                                isRefreshing: _isRefreshing,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Removed floatingActionButton completely
    );
  }
}

// Keep all the other widget classes the same but add debugging to _ReportsContent

class _ReportsContent extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;
  final bool isLargeScreen;
  final List<Map<String, dynamic>> liveByUserFormatted;
  final List<Map<String, dynamic>> liveAgainstUserFormatted;
  final List<Map<String, dynamic>> solvedByUserFormatted;
  final List<Map<String, dynamic>> solvedAgainstUserFormatted;
  final bool isRefreshing;

  const _ReportsContent({
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
    required this.isLargeScreen,
    required this.liveByUserFormatted,
    required this.liveAgainstUserFormatted,
    required this.solvedByUserFormatted,
    required this.solvedAgainstUserFormatted,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building _ReportsContent with:');
    print('  - Live by user: ${liveByUserFormatted.length}');
    print('  - Live against user: ${liveAgainstUserFormatted.length}');
    print('  - Solved by user: ${solvedByUserFormatted.length}');
    print('  - Solved against user: ${solvedAgainstUserFormatted.length}');
    print('  - Is refreshing: $isRefreshing');

    // If all lists are empty, show debug info
    if (liveByUserFormatted.isEmpty &&
        liveAgainstUserFormatted.isEmpty &&
        solvedByUserFormatted.isEmpty &&
        solvedAgainstUserFormatted.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.info, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Debug: All report lists are empty',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This means either:\n'
              '1. No reports were fetched from API\n'
              '2. Error in data formatting\n'
              '3. Reports exist but not being categorized properly',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Refresh indicator
        if (isRefreshing) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF31C5F4),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Refreshing reports...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],

        // Report sections
        if (liveByUserFormatted.isNotEmpty) ...[
          buildReportSection(
            context: context,
            title: "Live Reportings By You (${liveByUserFormatted.length})",
            reports: liveByUserFormatted,
            screenWidth: screenWidth,
            isTablet: isTablet,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: screenHeight * 0.02),
          buildDivider(screenWidth),
          SizedBox(height: screenHeight * 0.02),
        ],

        if (liveAgainstUserFormatted.isNotEmpty) ...[
          buildReportSection(
            context: context,
            title:
                "Live Reportings Against You (${liveAgainstUserFormatted.length})",
            reports: liveAgainstUserFormatted,
            screenWidth: screenWidth,
            isTablet: isTablet,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: screenHeight * 0.02),
          buildDivider(screenWidth),
          SizedBox(height: screenHeight * 0.02),
        ],

        if (solvedByUserFormatted.isNotEmpty) ...[
          buildReportSection(
            context: context,
            title: "Solved Reportings By You (${solvedByUserFormatted.length})",
            reports: solvedByUserFormatted,
            screenWidth: screenWidth,
            isTablet: isTablet,
            isLargeScreen: isLargeScreen,
          ),
          SizedBox(height: screenHeight * 0.02),
          buildDivider(screenWidth),
          SizedBox(height: screenHeight * 0.02),
        ],

        if (solvedAgainstUserFormatted.isNotEmpty) ...[
          buildReportSection(
            context: context,
            title:
                "Solved Reportings Against You (${solvedAgainstUserFormatted.length})",
            reports: solvedAgainstUserFormatted,
            screenWidth: screenWidth,
            isTablet: isTablet,
            isLargeScreen: isLargeScreen,
          ),
        ],

        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}

// Add these widget classes to your home_page.dart file

class _LoadingWidget extends StatelessWidget {
  final double screenHeight;

  const _LoadingWidget({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF31C5F4)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading reports...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final double screenHeight;
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.screenHeight,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF31C5F4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onRefresh;

  const _EmptyWidget({
    required this.screenHeight,
    required this.screenWidth,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.88,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.6,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Reports Yet',
                style: AppFonts.bold20().copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'No reportings made by you or against you',
                style: AppFonts.regular14().copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Color(0xFF31C5F4)),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: Color(0xFF31C5F4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF31C5F4)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
