# Generated by Django 5.1.3 on 2025-04-28 13:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0027_runningactivity_route_data'),
    ]

    operations = [
        migrations.AddField(
            model_name='walkingactivity',
            name='route_data',
            field=models.TextField(blank=True, null=True),
        ),
    ]
