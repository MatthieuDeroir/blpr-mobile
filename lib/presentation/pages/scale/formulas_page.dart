import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_constants.dart';
import 'package:mood_tracker/core/theme/app_colors.dart';
import 'package:mood_tracker/core/theme/app_text_styles.dart';
import 'package:mood_tracker/presentation/widgets/common/loading_indicator.dart';
import 'package:mood_tracker/presentation/widgets/scale/formula_card.dart';

class FormulasPage extends StatefulWidget {
  const FormulasPage({Key? key}) : super(key: key);

  @override
  State<FormulasPage> createState() => _FormulasPageState();
}

class _FormulasPageState extends State<FormulasPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _formulas = [];

  @override
  void initState() {
    super.initState();
    _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load from StabilityFormula bloc
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    _formulas = [
      {
        'id': AppConstants.defaultFormulaId,
        'description': 'Default formula with equal weights for all scales',
        'isDefault': true,
        'isActive': true,
        'scaleWeights': [
          {
            'scaleId': AppConstants.humeurScaleId,
            'scaleName': 'Mood (Humeur)',
            'weight': 1.0,
            'isInverted': false,
          },
          {
            'scaleId': AppConstants.irritabiliteScaleId,
            'scaleName': 'Irritability (Irritabilité)',
            'weight': 1.0,
            'isInverted': true,
          },
          {
            'scaleId': AppConstants.confianceScaleId,
            'scaleName': 'Confidence (Confiance)',
            'weight': 1.0,
            'isInverted': false,
          },
          {
            'scaleId': AppConstants.extraversionScaleId,
            'scaleName': 'Extraversion',
            'weight': 1.0,
            'isInverted': false,
          },
          {
            'scaleId': AppConstants.bienEtreScaleId,
            'scaleName': 'Well-being (Bien-être)',
            'weight': 1.0,
            'isInverted': false,
          },
        ],
      },
      {
        'id': 'custom-formula-1',
        'description': 'Custom formula with focus on mood and anxiety',
        'isDefault': false,
        'isActive': false,
        'scaleWeights': [
          {
            'scaleId': AppConstants.humeurScaleId,
            'scaleName': 'Mood (Humeur)',
            'weight': 2.0,
            'isInverted': false,
          },
          {
            'scaleId': AppConstants.irritabiliteScaleId,
            'scaleName': 'Irritability (Irritabilité)',
            'weight': 1.0,
            'isInverted': true,
          },
          {
            'scaleId': AppConstants.bienEtreScaleId,
            'scaleName': 'Well-being (Bien-être)',
            'weight': 1.5,
            'isInverted': false,
          },
        ],
      },
    ];

    setState(() {
      _isLoading = false;
    });
  }

  void _setActive(String id) {
    // TODO: Update via bloc
    setState(() {
      for (var formula in _formulas) {
        formula['isActive'] = formula['id'] == id;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formula set as active'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteFormula(String id) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Formula'),
        content: const Text('Are you sure you want to delete this formula? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // TODO: Delete via bloc
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _formulas.removeWhere((formula) => formula['id'] == id);
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formula deleted'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stability Formulas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/formula/add');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _formulas.isEmpty
          ? _buildEmptyState()
          : _buildFormulasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/formula/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.functions,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No custom formulas yet',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Create custom formulas to customize how your stability score is calculated',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/formula/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Formula'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulasList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _formulas.length,
      itemBuilder: (context, index) {
        final formula = _formulas[index];
        return FormulaCard(
          id: formula['id'],
          description: formula['description'],
          isDefault: formula['isDefault'],
          isActive: formula['isActive'],
          scaleWeights: List<Map<String, dynamic>>.from(formula['scaleWeights']),
          onSetActive: () => _setActive(formula['id']),
          onEdit: formula['isDefault']
              ? null
              : () {
            Navigator.of(context).pushNamed(
              '/formula/edit',
              arguments: formula['id'],
            );
          },
          onDelete: formula['isDefault'] ? null : () => _deleteFormula(formula['id']),
        );
      },
    );
  }
}