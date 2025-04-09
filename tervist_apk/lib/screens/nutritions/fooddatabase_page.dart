import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tervist_apk/screens/nutritions/selected_food_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tracking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      ),
      home: const FoodDatabasePage(),
    );
  }
}

class FoodDatabasePage extends StatefulWidget {
  const FoodDatabasePage({super.key});

  @override
  State<FoodDatabasePage> createState() => _FoodDatabasePageState();
}

class _FoodDatabasePageState extends State<FoodDatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  // Database makanan (simulasi)
  final List<Map<String, dynamic>> _allFoodItems = [
    {
      'name': 'White Rice',
      'calories': 135,
      'serving': 'serving',
      'selected': false
    },
    {'name': 'Egg', 'calories': 74, 'serving': 'large', 'selected': false},
    {'name': 'Fried Tofu', 'calories': 140, 'serving': '', 'selected': false},
    {
      'name': 'Cheese Pizza',
      'calories': 274,
      'serving': 'slice',
      'selected': false
    },
    {
      'name': 'Pizza with Meat',
      'calories': 285,
      'serving': 'slice',
      'selected': false
    },
    {
      'name': 'Pizza with Vegetables',
      'calories': 276,
      'serving': 'slice',
      'selected': false
    },
    {
      'name': 'Pepperoni Pizza',
      'calories': 305,
      'serving': 'slice',
      'selected': false
    },
    {
      'name': 'Thin Crust Cheese Pizza',
      'calories': 208,
      'serving': 'slice',
      'selected': false
    },
    {'name': 'Apple', 'calories': 95, 'serving': 'medium', 'selected': false},
    {'name': 'Banana', 'calories': 105, 'serving': 'medium', 'selected': false},
    {
      'name': 'Orange Juice',
      'calories': 110,
      'serving': 'cup',
      'selected': false
    },
    {
      'name': 'Chicken Breast',
      'calories': 165,
      'serving': '100g',
      'selected': false
    },
  ];

  late List<Map<String, dynamic>> _displayedFoodItems;
  late List<Map<String, dynamic>> _frequentlyAddedFood;

  @override
  void initState() {
    super.initState();

    // Inisialisasi list
    _displayedFoodItems = [];

    // Set makanan yang sering ditambahkan di awal
    _frequentlyAddedFood = [
      Map<String, dynamic>.from(_allFoodItems[0]), // White Rice
      Map<String, dynamic>.from(_allFoodItems[1]), // Egg
      Map<String, dynamic>.from(_allFoodItems[2]), // Fried Tofu
    ];

    // Listener untuk melakukan pencarian saat nilai input berubah
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        if (_searchQuery.isNotEmpty) {
          _filterFoodItems();
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

  // Fungsi untuk memfilter makanan berdasarkan input pengguna
  void _filterFoodItems() {
    if (_searchQuery.isEmpty) {
      _displayedFoodItems = [];
      return;
    }

    final lowercaseQuery = _searchQuery.toLowerCase();
    _displayedFoodItems = _allFoodItems
        .where((item) =>
            item['name'].toString().toLowerCase().contains(lowercaseQuery))
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // Toggle makanan yang dipilih
  void _toggleFoodSelection(int index) {
    setState(() {
      if (index >= 0 && index < _displayedFoodItems.length) {
        _displayedFoodItems[index]['selected'] =
            !_displayedFoodItems[index]['selected'];
      }
    });
  }

  // Toggle makanan frequently added
  void _toggleFrequentFoodSelection(int index) {
    setState(() {
      if (index >= 0 && index < _frequentlyAddedFood.length) {
        _frequentlyAddedFood[index]['selected'] =
            !_frequentlyAddedFood[index]['selected'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan resizeToAvoidBottomInset untuk menghindari overflow ketika keyboard muncul
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Food Database',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // Menggunakan SingleChildScrollView sebagai root untuk memungkinkan scrolling
      // saat keyboard muncul dan mengambil ruang
      body: SafeArea(
        child: GestureDetector(
          // Menutup keyboard saat tap di luar search field
          onTap: () {
            FocusScope.of(context).unfocus();
            // Jika pencarian kosong, kembali ke tampilan default
            if (_searchController.text.isEmpty) {
              setState(() {
                _isSearching = false;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            // SingleChildScrollView memungkinkan konten untuk scroll ketika keyboard muncul
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Search bar interaktif dengan warna background yang lebih terang
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Describe what you ate',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onTap: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterFoodItems();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Sisa konten dalam Expanded untuk mengisi ruang yang tersedia
                // dan memungkinkan scrolling
                Expanded(
                  child: SingleChildScrollView(
                    // Pengaturan physics untuk membuat scrolling halus
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tampilkan UI yang sesuai berdasarkan status pencarian
                        if (!_isSearching || _searchQuery.isEmpty) ...[
                          // Log empty meal button
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelectedFoodPage()));
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit,
                                    color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Log empty meal',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Recently logged title
                          Text(
                            'Recently logged',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // No food message
                          Text(
                            'You haven\'t uploaded any food. Here are our frequently added food',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Frequently added food items
                          ..._frequentlyAddedFood.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FoodItem(
                                name: item['name'] as String,
                                calories: item['calories'] as int,
                                serving: item['serving'] as String,
                                isSelected: item['selected'] as bool,
                                onTap: () =>
                                    _toggleFrequentFoodSelection(index),
                              ),
                            );
                          }),
                          // Tambahkan padding di bawah agar dapat scroll lebih banyak
                          const SizedBox(height: 100),
                        ] else if (_searchQuery.isNotEmpty) ...[
                          // Menampilkan hasil pencarian
                          if (_displayedFoodItems.isEmpty) ...[
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No results found for "$_searchQuery"',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Wrap ListView builder dengan Column agar dapat menambahkan padding di bawah
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title section
                                Text(
                                  'Select from database',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Daftar hasil pencarian
                                ListView.builder(
                                  // Gunakan shrinkWrap agar ListView menyesuaikan dengan konten
                                  shrinkWrap: true,
                                  // Matikan scroll internal ListView, karena SingleChildScrollView sudah menangani scrolling
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _displayedFoodItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _displayedFoodItems[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: FoodItem(
                                        name: item['name'] as String,
                                        calories: item['calories'] as int,
                                        serving: item['serving'] as String,
                                        isSelected: item['selected'] as bool,
                                        onTap: () =>
                                            _toggleFoodSelection(index),
                                      ),
                                    );
                                  },
                                ),
                                // Tambahkan padding di bawah agar dapat scroll lebih banyak
                                const SizedBox(height: 200),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodItem extends StatelessWidget {
  final String name;
  final int calories;
  final String serving;
  final bool isSelected;
  final VoidCallback onTap;

  const FoodItem({
    super.key,
    required this.name,
    required this.calories,
    required this.serving,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : const Color(0xFFEEF2F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: isSelected ? Colors.white : Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      serving.isNotEmpty
                          ? '$calories cal · $serving'
                          : '$calories cal',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 18)
                    : const Icon(Icons.add, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
