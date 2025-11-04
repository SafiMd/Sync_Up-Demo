# SyncUp - Smart Budget Planning

A comprehensive Flutter-based financial budgeting application with AI-powered insights, beautiful visualizations, and secure transaction management.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation & Running

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## ✨ Features

### 🏦 Bank Account Management
- **Account Linking**: Connect multiple bank accounts (Checking, Savings, Credit Cards)
- **Mock Plaid Integration**: Simulated bank connectivity for development/testing
- **Account Overview**: View balances and account details on the home screen
- **Multi-Account Support**: Track transactions across all linked accounts

### 💳 Transaction Management
- **Transaction History**: View all transactions with detailed information
- **Category Filtering**: Filter transactions by category (13+ categories supported)
- **Real-time Updates**: Transactions automatically refresh and update
- **Search & Sort**: Easily find specific transactions
- **Transaction Details**: View merchant name, date, amount, and category
- **Visual Indicators**: Color-coded income (green) vs expenses (red)

### 💰 Budget Insights & Analytics

#### Overview Tab
- **Budget Alerts**: Track categories at ≥80% usage with color-coded warnings
- **Category Tracking**: Monitor all 13 spending categories
- **Total Budget Display**: See your complete monthly budget at a glance
- **Quick Stats**: Total spent, total budget, and remaining balance
- **Available Budget Card**: 
  - Shows available budget with income, expenses, and net savings
  - Color-coded (green for positive, red for negative/over budget)
  - Warning alerts when over budget

#### Charts Tab
- **Interactive Pie Chart**: 
  - Visual spending breakdown by category
  - Click any slice to view category transactions
  - Over-budget categories highlighted in red
  - Color-coded legend with percentages
- **Interactive Bar Chart**:
  - Budget usage percentage by category (top 12)
  - Click any bar to view transactions
  - Color-coded bars (green/blue/orange/red) based on usage
  - Thick borders on over-budget categories
  - Tooltips with spending details and "tap to view" hints
- **Clickable Legend**: 
  - Tap any category to view its transactions
  - Over-budget items highlighted with warning icons
  - Shows percentage of total spending

### 📊 AI-Powered Budget Management
- **Smart Budget Recommendations**: AI-calculated budgets based on income percentage
- **13 Category Coverage**: 
  - Food and Drink (15% of income)
  - Shops (10%)
  - Recreation (5%)
  - Travel (10%)
  - Service (15%)
  - Transportation (12%)
  - Healthcare (8%)
  - Entertainment (5%)
  - Education (10%)
  - Utilities (8%)
  - Insurance (10%)
  - Personal Care (5%)
- **Custom Budget Setting**: Override AI recommendations with custom budget amounts
- **Real-time Recalculation**: Budgets update instantly as you modify them
- **Budget Status Tracking**: Good, Moderate, Warning, Over Budget indicators
- **Personalized Advice**: AI-generated recommendations for each category

### 🎨 Budget Management Interface
- **Visual Budget Editor**: Easy-to-use interface for all categories
- **Progress Indicators**: Linear progress bars showing budget usage
- **Color-Coded Status**: Visual feedback (green/blue/orange/red)
- **Transaction Counts**: See number of transactions per category
- **Average Spending**: Track average transaction amounts
- **Save & Reset**: Save custom budgets or reset to AI recommendations
- **Negative Budget Support**: Shows over-budget amounts in red with minus sign

### 🔒 Security & Encryption
- **AES-256 Encryption**: Bank-grade encryption for sensitive data
- **Secure Data Storage**: Transaction data encrypted at rest
- **Encryption Service**: Located in `/services/encryption_service.dart`

### 🎯 Additional Features
- **Beautiful Modern UI**: Gradient designs, smooth animations, and polished UX
- **Responsive Design**: Works on all screen sizes
- **Loading Animations**: Custom loading indicators throughout the app
- **Error Handling**: Graceful error messages and fallbacks
- **State Management**: Provider-based architecture for reactive updates
- **Interactive Dialogs**: Transaction popup dialogs with detailed information
- **Date Formatting**: User-friendly date displays (e.g., "Oct 8, 2025")

## 📱 App Structure

### Screens
- `home_screen.dart` - Dashboard with account overview and quick actions
- `link_account_screen.dart` - Bank account connection interface
- `transactions_screen.dart` - Transaction history with filtering
- `insights_screen.dart` - Budget insights with charts (Overview & Charts tabs)
- `budget_management_screen.dart` - Budget customization for all categories

### Services
- `plaid_service.dart` - Mock bank connectivity (Plaid API integration ready)
- `budget_ai_service.dart` - AI-powered budget calculations and insights
- `encryption_service.dart` - AES-256 encryption for data security

### Models
- `account.dart` - Bank account data structure
- `transaction.dart` - Transaction data model
- `budget_insight.dart` - Budget analysis and recommendations

### Widgets
- `animated_button.dart` - Custom gradient buttons with animations
- `loading_animation.dart` - Beautiful loading indicators
- `budget_charts.dart` - Interactive pie charts, bar charts, and legends

## 📊 Sample Data

The app includes rich sample data with:
- 3 bank accounts (Checking, Savings, Credit Card)
- 40+ transactions across 13 categories
- Realistic spending patterns
- Income deposits (transfers)
- Various merchants and transaction types

## 🎥 Demo Videos

**V1.0 (09/30/2025)**:  
https://drive.google.com/file/d/1eyZpr8-gNg6tyQ-pWMgAHcoXAdwSsIlw/view?usp=sharing

*Will be updated with future demo versions.*

## 🔮 Future Enhancements

### Planned Features
1. **Plaid API Integration**: Replace mock data with real bank connections
2. **Biometric Authentication**: Face ID / Touch ID for app access
3. **Savings Goals**: Set and track financial goals
4. **Spending Trends**: Historical analysis and predictions
5. **Bill Reminders**: Notifications for upcoming bills
6. **Export Reports**: PDF/CSV export of financial data
7. **Multi-Currency Support**: International currency handling
8. **Recurring Transactions**: Automatic detection and categorization
9. **Split Transactions**: Split expenses across categories
10. **Budget Templates**: Pre-built budget templates for different lifestyles

### Technical Improvements
1. **Cloud Sync**: Cross-device synchronization
2. **Offline Mode**: Full functionality without internet
3. **Performance Optimization**: Faster load times and smoother animations
4. **Unit & Integration Tests**: Comprehensive test coverage
5. **CI/CD Pipeline**: Automated testing and deployment

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Charts**: fl_chart
- **Encryption**: encrypt package (AES-256)
- **Date Formatting**: intl package
