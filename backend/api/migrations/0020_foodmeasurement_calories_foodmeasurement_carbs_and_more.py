# Generated by Django 5.1.3 on 2025-04-10 00:22

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0019_remove_fooddatabase_measurement_foodmeasurement'),
    ]

    operations = [
        migrations.AddField(
            model_name='foodmeasurement',
            name='calories',
            field=models.FloatField(default=0.0),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='foodmeasurement',
            name='carbs',
            field=models.FloatField(default=0.0),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='foodmeasurement',
            name='fat',
            field=models.FloatField(default=0.0),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='foodmeasurement',
            name='protein',
            field=models.FloatField(default=0.0),
            preserve_default=False,
        ),
    ]
