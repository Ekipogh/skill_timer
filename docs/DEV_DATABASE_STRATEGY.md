# Pre-Release Database Development Strategy

## TL;DR: **Yes, it's OK to nuke the DB during development!**

For internal pre-release development, **resetting the database is not only acceptable but often recommended**. Here's a practical strategy for your development phases.

## 🚀 Development Phase Strategy

### **Phase 1: Active Development (Current)**
**Status**: Schema experimentation and major feature development
**Approach**: **🔥 Reset DB Freely**

```dart
// Use this liberally during active development
await DBProvider.devReset(reason: 'Testing new skill categories schema');
await DBProvider.addSampleData(); // Quick test data
```

**✅ When to Reset:**
- Major schema changes (adding/removing tables)
- Changing column types or constraints
- Experimenting with new features
- Refactoring data relationships
- When migrations would be more complex than the benefit

**✅ Benefits:**
- **Faster development** - no complex migration logic needed
- **Cleaner schema** - start fresh with optimal design
- **Less bugs** - avoid migration edge cases during experimentation
- **Focus on features** - not on maintaining compatibility

### **Phase 2: Feature Stabilization (Pre-Beta)**
**Status**: 2-3 weeks before first beta/public testing
**Approach**: **🏗️ Start Using Migrations**

```dart
// Begin migration discipline
static const int databaseVersion = 2; // Increment versions
// Document all changes in migrationHistory
```

**✅ When to Migrate:**
- Schema is relatively stable
- Adding minor features
- Beta testers will use the app
- Want to practice migration workflows

### **Phase 3: Release Preparation (Beta+)**
**Status**: Public testing and release candidates
**Approach**: **🔒 Strict Migrations Only**

```dart
// No more resets - only proper migrations
await _runMigration(db, newVersion);
```

## 🛠 Development Tools Added

### **Easy Reset Commands**
```dart
// Quick reset during development
await DBProvider.devReset(reason: 'Major schema redesign');

// Safe reset with checks
await DBProvider.safeDevReset(reason: 'Testing new features');

// Add sample data after reset
await DBProvider.addSampleData();
```

### **Development Widget**
Add to your app during development:

```dart
// In your main screen (development only)
Column(
  children: [
    // Your normal app content
    // ...existing code...

    // Development tools (only shows in dev mode)
    DevDatabaseUtils(),
  ],
)
```

### **Safety Checks**
```dart
// Automatic protection against production resets
static bool get canSafelyReset {
  return AppConstants.isDevelopmentMode ||
         AppConstants.appVersion.contains('dev') ||
         AppConstants.databaseVersion < 2;
}
```

## 📊 Decision Matrix

| Situation | Reset DB | Use Migration | Reasoning |
|-----------|----------|---------------|-----------|
| **Adding experimental table** | ✅ | ❌ | Might remove it later |
| **Changing column types** | ✅ | ❌ | Complex migration for experimental feature |
| **Removing unused table** | ✅ | ❌ | Cleaner to start fresh |
| **Adding single column** | ⚠️ | ✅ | Good migration practice |
| **2 weeks before beta** | ❌ | ✅ | Start preserving test data |
| **Beta testing active** | ❌ | ✅ | Must preserve user data |
| **Production release** | ❌ | ✅ | Never reset production data |

## 🎯 Practical Examples

### **Scenario 1: Adding Timer Sessions Feature**
```dart
// DEVELOPMENT APPROACH (Current phase)
await DBProvider.devReset(reason: 'Adding timer sessions feature');
// Modify schema in _migrationV1 directly
// Test the feature thoroughly

// LATER (Pre-release phase)
// Create _migrationV2 for timer sessions
// Test upgrade path: V1 → V2
```

### **Scenario 2: Redesigning Skill Categories**
```dart
// DEVELOPMENT APPROACH
await DBProvider.devReset(reason: 'Redesigning skill categories');
// Change the entire schema design
// Experiment with different approaches

// PRODUCTION APPROACH (Later)
// Create careful migration to transform existing data
// Test with real user data
```

### **Scenario 3: Adding User Preferences**
```dart
// DEVELOPMENT APPROACH
await DBProvider.devReset(reason: 'Adding user preferences');
// Add preferences table to _migrationV1
// Test preferences functionality

// STABLE APPROACH (Later)
// Create _migrationV3 for preferences
// Provide sensible defaults for existing users
```

## 🧪 Testing Strategy

### **Development Testing**
```dart
// Test schema changes quickly
await DBProvider.devReset();
await DBProvider.addSampleData();
// Test your feature
// Reset and test again
```

### **Pre-Release Testing**
```dart
// Test migration paths
await DevMigrationUtils.simulateMigration(1, 2);
await DevMigrationUtils.simulateMigration(1, 3);
// Ensure data preservation
```

## 📝 Best Practices for Your Current Phase

### **✅ DO (Current Development Phase)**
1. **Reset liberally** when experimenting with schema
2. **Focus on getting the schema right** before worrying about migrations
3. **Use sample data** to test features quickly
4. **Document major changes** in commit messages
5. **Keep the migration framework** ready for later phases

### **✅ DON'T (Current Development Phase)**
1. **Don't worry about complex migrations** for experimental features
2. **Don't spend time on data preservation** for features you might remove
3. **Don't increment database versions** until schema stabilizes
4. **Don't stress about breaking changes** during experimentation

### **🔄 Transition Strategy**
When you're ready to move to migration-based development:

1. **Finalize your V1 schema** - this becomes your baseline
2. **Create comprehensive sample data** - test migration with realistic data
3. **Set `databaseVersion = 2`** - begin strict versioning
4. **Switch to migration-only changes** - no more resets
5. **Test upgrade paths** - ensure smooth transitions

## 🎉 Your Current Setup

Your app now has the best of both worlds:

```dart
// Development mode - reset freely
await DBProvider.devReset(reason: 'Major feature changes');

// Production mode - strict migrations
// Automatically prevented in production builds
```

**Bottom Line**: You're in the perfect phase to reset the database freely. Take advantage of this flexibility to get your schema right, then transition to migrations when you're ready for public testing!
