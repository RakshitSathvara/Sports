#!/bin/bash

echo "🚀 Starting OQDO Flutter theme migration..."
echo "Creating backup of lib directory..."

# Create backup
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

echo "📝 Migrating ColorsUtils calls..."
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greyButton/ColorsUtils.of(context).greyButton/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greyCircle/ColorsUtils.of(context).greyCircle/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.redColor/ColorsUtils.of(context).redColor/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.redDeleteColor/ColorsUtils.of(context).redDeleteColor/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.vacationList/ColorsUtils.of(context).vacationList/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greyText/ColorsUtils.of(context).greyText/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.subTitle/ColorsUtils.of(context).subTitle/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.chipBackground/ColorsUtils.of(context).chipBackground/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.chipText/ColorsUtils.of(context).chipText/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.edittextBackProfile/ColorsUtils.of(context).edittextBackProfile/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.white/ColorsUtils.of(context).white/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.messageLeft/ColorsUtils.of(context).messageLeft/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.messageRight/ColorsUtils.of(context).messageRight/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greyTab/ColorsUtils.of(context).greyTab/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greyAmount/ColorsUtils.of(context).greyAmount/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.redAmount/ColorsUtils.of(context).redAmount/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.greenAmount/ColorsUtils.of(context).greenAmount/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.pendingAmount/ColorsUtils.of(context).pendingAmount/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/ColorsUtils\.yellowStatus/ColorsUtils.of(context).yellowStatus/g' {} \;

echo "🎨 Migrating OQDOThemeData calls..."
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.whiteColor/Theme.of(context).colorScheme.background/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.blackColor/Theme.of(context).colorScheme.onBackground/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.greyColor/Theme.of(context).colorScheme.onSurface/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.backgroundColor/Theme.of(context).colorScheme.background/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.dividerColor/Theme.of(context).colorScheme.primary/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.otherTextColor/Theme.of(context).colorScheme.onSurface.withOpacity(0.6)/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/OQDOThemeData\.filterDividerColor/Theme.of(context).colorScheme.outline/g' {} \;

echo "🏠 Migrating common color patterns..."
find lib -name "*.dart" -type f -exec sed -i '' 's/color: Colors\.white/color: Theme.of(context).colorScheme.background/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/backgroundColor: Colors\.white/backgroundColor: Theme.of(context).colorScheme.background/g' {} \;

echo "✅ Migration complete!"
