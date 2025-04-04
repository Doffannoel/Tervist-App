# Generated by Django 5.1.3 on 2025-03-23 10:44

import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0011_alter_fooddatabase_measurement'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='RunningActivity',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('distance_km', models.FloatField()),
                ('time_seconds', models.IntegerField()),
                ('pace', models.FloatField()),
                ('calories_burned', models.IntegerField()),
                ('steps', models.IntegerField()),
                ('date', models.DateField(default=django.utils.timezone.now)),
                ('user', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
