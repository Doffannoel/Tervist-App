import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/api/food_database_service.dart';
import '../../models/food_database.dart';
import 'food_detail_page.dart';

class FoodDatabasePage extends StatefulWidget {
  const FoodDatabasePage({super.key});

  @override
  State<FoodDatabasePage> createState() => _FoodDatabasePageState();
}

class _FoodDatabasePageState extends State<FoodDatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FoodDatabaseService _foodService = FoodDatabaseService();

  bool _isSearching = false;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingRecent = false;

  List<FoodDatabase> _searchResults = [];
  List<FoodDatabase> _recentlyLoggedFood = [];

  @override
  void initState() {
    super.initState();
    _loadRecentlyLoggedFood();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        if (_searchQuery.isNotEmpty) {
          _searchFoodItems();
        } else {
          _searchResults = [];
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentlyLoggedFood() async {
    if (_isLoadingRecent) return;
    setState(() => _isLoadingRecent = true);
    try {
      final recentFoods = await _foodService.getRecentlyLoggedFood();
      setState(() => _recentlyLoggedFood = recentFoods);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recently logged foods: $e')),
      );
    } finally {
      setState(() => _isLoadingRecent = false);
    }
  }

  Future<void> _searchFoodItems() async {
    if (_searchQuery.isEmpty || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final results =
          await _foodService.getFoodItems(searchQuery: _searchQuery);
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching for food: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logFood(FoodDatabase food) async {
    try {
      await _foodService.logFoodIntake(
        foodDataId: food.id,
        servingSize: "1",
        mealType: _getMealTypeBasedOnTime(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${food.name} logged successfully')),
      );
      _loadRecentlyLoggedFood();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging food: $e')),
      );
    }
  }

  String _getMealTypeBasedOnTime() {
    final hour = TimeOfDay.now().hour;
    if (hour >= 5 && hour < 10) return 'Breakfast';
    if (hour >= 10 && hour < 15) return 'Lunch';
    if (hour >= 15 && hour < 20) return 'Dinner';
    return 'Snack';
  }

  void _navigateToFoodDetail(FoodDatabase food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailPage(food: food)),
    ).then((_) => _loadRecentlyLoggedFood());
  }

  void _navigateToLogEmptyMeal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Log empty meal feature will be implemented later')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Food Database',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8EF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Describe what you ate',
                    hintStyle:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onTap: () => setState(() => _isSearching = true),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isSearching || _searchQuery.isEmpty) ...[
                        OutlinedButton(
                          onPressed: _navigateToLogEmptyMeal,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.edit,
                                    color: Colors.black, size: 18),
                                const SizedBox(width: 70),
                                Text('Log empty meal',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text('Recently logged',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_isLoadingRecent)
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator()))
                        else if (_recentlyLoggedFood.isEmpty)
                          Text('You haven\'t logged any food yet.',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.black87))
                        else
                          ..._recentlyLoggedFood.map((food) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: FoodItem(
                                  food: food,
                                  onTapDetail: () =>
                                      _navigateToFoodDetail(food),
                                  onTapLog: () => _logFood(food),
                                ),
                              )),
                      ] else if (_searchQuery.isNotEmpty) ...[
                        if (_isLoading)
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator()))
                        else if (_searchResults.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off,
                                      size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text('No results found for "$_searchQuery"',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.grey.shade600),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select from database',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              ..._searchResults.map((food) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: FoodItem(
                                      food: food,
                                      onTapDetail: () =>
                                          _navigateToFoodDetail(food),
                                      onTapLog: () => _logFood(food),
                                    ),
                                  )),
                              const SizedBox(height: 100),
                            ],
                          ),
                      ],
                    ],
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

class FoodItem extends StatelessWidget {
  final FoodDatabase food;
  final VoidCallback onTapDetail;
  final VoidCallback onTapLog;

  const FoodItem(
      {super.key,
      required this.food,
      required this.onTapDetail,
      required this.onTapLog});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapDetail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 16),
                      const SizedBox(width: 4),
                      Text(
                          '${food.measurements.isNotEmpty ? food.measurements.first.calories.toStringAsFixed(0) : '0'} cal · ${food.measurements.isNotEmpty ? food.measurements.first.label : '-'}',
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onTapLog,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.black, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
