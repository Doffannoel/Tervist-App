# Generated by Django 5.1.3 on 2025-04-06 15:41

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0016_cyclingactivity'),
    ]

    operations = [
        migrations.AlterField(
            model_name='caloriesburned',
            name='bmr_calories',
            field=models.IntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='caloriesburned',
            name='exercise_calories',
            field=models.IntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='caloriesburned',
            name='total_calories',
            field=models.IntegerField(blank=True, null=True),
        ),
    ]
