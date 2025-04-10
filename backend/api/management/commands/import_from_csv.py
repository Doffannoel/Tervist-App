import pandas as pd
import os
from django.core.management.base import BaseCommand
from api.models import FoodDatabase, FoodMeasurement

class Command(BaseCommand):
    help = 'Import food and measurement data from cleaned CSV'

    def handle(self, *args, **kwargs):
        csv_path = os.path.join('api', 'management', 'commands', 'Cleaned_Nutrition_Data.csv')

        if not os.path.exists(csv_path):
            self.stdout.write(self.style.ERROR(f"File not found: {csv_path}"))
            return

        df = pd.read_csv(csv_path)

        # Bersihkan kolom nama makanan
        df['Food Name'] = df['Food Name'].ffill()

        # Fungsi buat bersihin koma jadi titik dan ubah ke float
        def clean_float(val):
            if pd.isna(val):
                return 0.0
            if isinstance(val, str):
                return float(val.replace(',', '.').strip())
            return float(val)

        # Terapin ke semua kolom numerik
        for col in [
            'Calories', 'Protein', 'Total Carbs', 'Total Fat',
            'Saturated Fat', 'Polyunsaturated Fat', 'Monounsaturated Fat',
            'Cholesterol', 'Sodium', 'Dietary Fiber', 'Total Sugars',
            'Potassium', 'Vitamin A', 'Vitamin C', 'Calcium', 'Iron',
            'Gram Equivalent'
        ]:
            df[col] = df[col].apply(clean_float)

        # Hapus data lama
        FoodMeasurement.objects.all().delete()
        FoodDatabase.objects.all().delete()
        self.stdout.write(self.style.WARNING("Deleted old FoodDatabase & FoodMeasurement data"))

        # Group by food name
        grouped = df.groupby('Food Name')
        count = 0

        for food_name, group in grouped:
            food = FoodDatabase.objects.create(name=food_name)
            for _, row in group.iterrows():
                FoodMeasurement.objects.create(
                    food=food,
                    label=row['Measurement'],
                    gram_equivalent=row['Gram Equivalent'],
                    calories=row['Calories'],
                    protein=row['Protein'],
                    carbs=row['Total Carbs'],
                    fat=row['Total Fat'],
                    saturated_fat=row['Saturated Fat'],
                    polyunsaturated_fat=row['Polyunsaturated Fat'],
                    monounsaturated_fat=row['Monounsaturated Fat'],
                    cholesterol=row['Cholesterol'],
                    sodium=row['Sodium'],
                    dietary_fiber=row['Dietary Fiber'],
                    total_sugars=row['Total Sugars'],
                    potassium=row['Potassium'],
                    vitamin_a=row['Vitamin A'],
                    vitamin_c=row['Vitamin C'],
                    calcium=row['Calcium'],
                    iron=row['Iron'],
                )
            count += 1
            self.stdout.write(self.style.SUCCESS(f"Imported: {food_name}"))

        self.stdout.write(self.style.SUCCESS(f"Successfully imported {count} foods from CSV"))
