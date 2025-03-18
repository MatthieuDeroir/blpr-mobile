import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/scale/scale_card.dart';

class ScalesPage extends StatefulWidget {
  const ScalesPage({Key? key}) : super(key: key);

  @override
  State<ScalesPage> createState() => _ScalesPageState();
}

class _ScalesPageState extends State<ScalesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // TODO: Replace with data from bloc
  final List<Map<String, dynamic>> _defaultScales = [
    {
      'id': AppConstants.humeurScaleId,
      'name': 'Mood (Humeur)',
      'description': 'Scale for measuring mood between depression and mania',
      'isDefault': true,
      'minValue': 0,
      'maxValue': 13,
      'isActive': true,
    },
    {
      'id': AppConstants.irritabiliteScaleId,
      'name': 'Irritability (Irritabilité)',
      'description': 'Scale for measuring irritability and anger levels',
      'isDefault': true,
      'minValue': 0,
      'maxValue': 13,
      'isActive': true,
    },
    {
      'id': AppConstants.confianceScaleId,
      'name': 'Confidence (Confiance)',
      'description': 'Scale for measuring self-confidence and esteem',
      'isDefault': true,
      'minValue': 0,
      'maxValue': 13,
      'isActive': true,
    },
    {
      'id': AppConstants.extraversionScaleId,
      'name': 'Extraversion',
      'description': 'Scale for measuring sociability and extraversion',
      'isDefault': true,
      'minValue': 0,
      'maxValue': 13,
      'isActive': true,
    },
    {
      'id': AppConstants.bienEtreScaleId,
      'name': 'Well-being (Bien-être)',
      'description': 'Scale for measuring general well-being and anxiety',
      'isDefault': true,
      'minValue': 0,
      'maxValue': 13,
      'isActive': true,
    },
  ];

  final List<Map<String, dynamic>> _customScales = [
    {
      'id': 'custom-1',
      'name': 'Energy Level',
      'description': 'Custom scale for tracking daily energy levels',
      'isDefault': false,
      'minValue': 0,
      'maxValue': 10,
      'isActive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadScales() {
    // TODO: Load scales from bloc
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Default Scales'),
            Tab(text: 'Custom Scales'),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Default scales tab
              _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _buildScalesList(_defaultScales, isEditable: false),

              // Custom scales tab
              _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _customScales.isEmpty
                  ? _buildEmptyState()
                  : _buildScalesList(_customScales, isEditable: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScalesList(List<Map<String, dynamic>> scales, {required bool isEditable}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scales.length,
      itemBuilder: (context, index) {
        final scale = scales[index];
        return ScaleCard(
          id: scale['id'],
          name: scale['name'],
          description: scale['description'],
          minValue: scale['minValue'],
          maxValue: scale['maxValue'],
          isActive: scale['isActive'],
          isDefault: scale['isDefault'],
          isEditable: isEditable,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.scale,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No custom scales yet',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first custom scale',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/scale/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Scale'),
          ),
        ],
      ),
    );
  }
}