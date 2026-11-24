from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('artisans', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='artisanprofile',
            name='experience_years',
            field=models.PositiveIntegerField(blank=True, default=0, null=True),
        ),
    ]

