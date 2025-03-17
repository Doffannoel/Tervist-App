from django.core.management.base import BaseCommand
from api.models import FoodDatabase

class Command(BaseCommand):
    help = 'Import food data using hardcoded values'

    def handle(self, *args, **kwargs):
        # Clear existing data
        FoodDatabase.objects.all().delete()
        self.stdout.write("Cleared existing database entries")
        
        # Define all food data manually based on your provided sample
        food_data = [
            # Egg with different measurements
            {"name": "Egg", "measurement": "Per gram", "calories": 1.48, "protein": 0.12, "carbs": 0.0, "fat": 0.08},
            {"name": "Egg", "measurement": "Small", "calories": 56.24, "protein": 4.56, "carbs": 0.0, "fat": 3.04},
            {"name": "Egg", "measurement": "Medium", "calories": 65.12, "protein": 5.28, "carbs": 0.0, "fat": 3.52},
            {"name": "Egg", "measurement": "Large", "calories": 74, "protein": 6, "carbs": 0.0, "fat": 4.0},
            {"name": "Egg", "measurement": "Extra Large", "calories": 88.8, "protein": 7.2, "carbs": 0.0, "fat": 4.8},
            {"name": "Egg", "measurement": "Jumbo", "calories": 103.6, "protein": 8.4, "carbs": 0.0, "fat": 5.6},
            
            # Boiled Egg with different measurements
            {"name": "Boiled Egg", "measurement": "Per serving (150 g)", "calories": 211, "protein": 17.1, "carbs": 1.5, "fat": 14.4},
            {"name": "Boiled Egg", "measurement": "Per gram", "calories": 3.02, "protein": 0.24, "carbs": 0.01, "fat": 0.1},
            {"name": "Boiled Egg", "measurement": "Small", "calories": 114.57, "protein": 9.29, "carbs": 0.38, "fat": 3.8},
            {"name": "Boiled Egg", "measurement": "Medium", "calories": 132.72, "protein": 10.76, "carbs": 0.44, "fat": 4.4},
            {"name": "Boiled Egg", "measurement": "Large", "calories": 150.65, "protein": 12.21, "carbs": 0.5, "fat": 5.0},
            {"name": "Boiled Egg", "measurement": "Jumbo", "calories": 211, "protein": 17.1, "carbs": 0.7, "fat": 7.0},
            
            # Avocado with different measurements
            {"name": "Avocado", "measurement": "Per serving (150 g)", "calories": 322, "protein": 4, "carbs": 17.2, "fat": 29.5},
            {"name": "Avocado", "measurement": "Per gram", "calories": 2.15, "protein": 0.027, "carbs": 0.11, "fat": 0.2},
            
            # Avocado Salad with different measurements
            {"name": "Avocado Salad", "measurement": "Per serving (300 g)", "calories": 513, "protein": 7.3, "carbs": 33.4, "fat": 43.7},
            {"name": "Avocado Salad", "measurement": "Per gram", "calories": 1.71, "protein": 0.024, "carbs": 0.11, "fat": 0.15},
            
            # Cheese Pizza with different measurements
            {"name": "Cheese Pizza", "measurement": "Per slice (100 g)", "calories": 274, "protein": 11.7, "carbs": 34.3, "fat": 10.0},
            {"name": "Cheese Pizza", "measurement": "Per gram", "calories": 2.74, "protein": 0.117, "carbs": 0.343, "fat": 0.1},
            
            # 14" Pepperoni Pizza with different measurements
            {"name": "14\" Pepperoni Pizza", "measurement": "Per gram", "calories": 3.04, "protein": 0.122, "carbs": 0.338, "fat": 0.133},
            {"name": "14\" Pepperoni Pizza", "measurement": "Per slice (98.0 g)", "calories": 298, "protein": 12.0, "carbs": 33.1, "fat": 13.0},
            
            # Pizza with Meat with different measurements
            {"name": "Pizza with Meat", "measurement": "Per gram", "calories": 3.22, "protein": 0.15, "carbs": 0.345, "fat": 0.148},
            {"name": "Pizza with Meat", "measurement": "Per serving (82.3 g)", "calories": 265, "protein": 12.3, "carbs": 28.4, "fat": 12.2},
            
            # Pizza with Meat and Vegetables with different measurements
            {"name": "Pizza with Meat and Vegetables", "measurement": "Per gram", "calories": 3.32, "protein": 0.15, "carbs": 0.345, "fat": 0.148},
            {"name": "Pizza with Meat and Vegetables", "measurement": "Per slice (83.1 g)", "calories": 276, "protein": 12.5, "carbs": 28.7, "fat": 12.3},
            
            # Thin Crust Cheese Pizza with different measurements
            {"name": "Thin Crust Cheese Pizza", "measurement": "Per gram", "calories": 2.71, "protein": 0.116, "carbs": 0.281, "fat": 0.127},
            {"name": "Thin Crust Cheese Pizza", "measurement": "Per slice (76.8 g)", "calories": 208, "protein": 8.9, "carbs": 21.6, "fat": 9.8},
            
            # Thick Crust Pizza with Meat with different measurements
            {"name": "Thick Crust Pizza with Meat", "measurement": "Per gram", "calories": 3, "protein": 0.1, "carbs": 0.3, "fat": 0.1},
            {"name": "Thick Crust Pizza with Meat", "measurement": "Per slice (102 g)", "calories": 305, "protein": 10.2, "carbs": 30.6, "fat": 10.2},
            
            # White Rice with different measurements
            {"name": "White Rice", "measurement": "Per gram", "calories": 1, "protein": 0, "carbs": 0.3, "fat": 0},
            {"name": "White Rice", "measurement": "Per serving (135 g)", "calories": 135, "protein": 0, "carbs": 40.5, "fat": 0},
            
            # Fried Tofu with different measurements
            {"name": "Fried Tofu", "measurement": "Per piece (20 g)", "calories": 35, "protein": 2.4, "carbs": 1.2, "fat": 2.6},
            {"name": "Fried Tofu", "measurement": "Per gram", "calories": 1.75, "protein": 0.12, "carbs": 0.06, "fat": 0.13},
        ]
        
        # Create records
        count = 0
        for item in food_data:
            try:
                # Create with default values for fields not specified
                food_item = FoodDatabase(
                    name=item["name"],
                    measurement=item["measurement"],
                    calories=item.get("calories", 0),
                    protein=item.get("protein", 0),
                    carbs=item.get("carbs", 0),
                    fat=item.get("fat", 0),
                    saturated_fat=item.get("saturated_fat", 0),
                    trans_fat=item.get("trans_fat", 0),
                    monounsaturated_fat=item.get("monounsaturated_fat", 0),
                    polyunsaturated_fat=item.get("polyunsaturated_fat", 0),
                    dietary_fiber=item.get("dietary_fiber", 0),
                    total_sugars=item.get("total_sugars", 0),
                    net_carbs=item.get("net_carbs", 0),
                    cholesterol=item.get("cholesterol", 0),
                    sodium=item.get("sodium", 0),
                    potassium=item.get("potassium", 0),
                    vitamin_a=item.get("vitamin_a", 0),
                    vitamin_c=item.get("vitamin_c", 0),
                    calcium=item.get("calcium", 0),
                    iron=item.get("iron", 0),
                )
                food_item.save()
                count += 1
                self.stdout.write(f"Added: {item['name']} ({item['measurement']})")
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Error adding {item['name']} ({item['measurement']}): {str(e)}"))
        
        self.stdout.write(self.style.SUCCESS(f"Successfully imported {count} food items"))