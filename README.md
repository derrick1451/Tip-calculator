# 💰 Tip Calculator

A comprehensive tip calculator web application built with Ruby on Rails 8. Calculate tips, split bills among groups, and track all calculations through an admin dashboard.

![Ruby](https://img.shields.io/badge/Ruby-3.2+-red?style=flat-square&logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.0-red?style=flat-square&logo=rubyonrails)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql)

## ✨ Features

### Tip Calculator
- **Quick tip selection**: Preset buttons for 5%, 10%, 15%, 25%, and 50% tips
- **Custom tip input**: Enter any tip percentage between 0-100%
- **Bill splitting**: Split the total among any number of people
- **Real-time calculations**: Instant updates as you type (powered by Stimulus.js)
- **Calculation persistence**: All calculations are saved for later review
- **Responsive design**: Works perfectly on desktop, tablet, and mobile devices

### Admin Dashboard (`/admin/dashboard`)
- **Complete calculation history**: View all saved tip calculations
- **Sortable data**: Sort by date, bill amount, or tip percentage
- **Pagination**: Navigate through large datasets easily
- **Summary statistics**: See total calculations, average tip %, average bill amount, and more
- **Custom Login Page**: Beautiful, styled authentication with session-based security
- **Toast Notifications**: Visual feedback when calculations are saved

## 🚀 Getting Started

### Prerequisites

- **Ruby**: 3.2 or higher
- **Rails**: 8.0.3
- **PostgreSQL**: 15 or higher
- **Node.js**: 18+ (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tip-calculator.git
   cd tip-calculator
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Configure the database**
   
   Update `config/database.yml` with your PostgreSQL credentials if needed:
   ```yaml
   default: &default
     adapter: postgresql
     encoding: unicode
     pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
     username: your_username
     password: your_password
   ```

4. **Create and migrate the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```
   
   Or simply:
   ```bash
   bin/rails server
   ```

6. **Visit the application**
   - Tip Calculator: http://localhost:3000
   - Admin Dashboard: http://localhost:3000/admin/dashboard

## 📖 Usage Guide

### Using the Tip Calculator

1. **Enter the bill amount** in the top input field
2. **Select a tip percentage** by clicking a preset button (5%, 10%, 15%, 25%, 50%) or entering a custom percentage
3. **Adjust the number of people** using the +/- buttons or by typing directly
4. **View the results** showing tip amount, total bill, and per-person amount
5. **Click "Save Calculation"** to save and view a summary, or **"Reset"** to start over

### Accessing the Admin Dashboard

1. Navigate to `/admin/dashboard`
2. You'll be redirected to the login page
3. Enter the credentials:
   - **Username**: `admin`
   - **Password**: `tipcalculator2026`
4. View, sort, and analyze all saved calculations
5. Click "Logout" to end your session

> **Note**: To customize admin credentials, set these environment variables:
> ```bash
> export ADMIN_USERNAME=your_username
> export ADMIN_PASSWORD=your_secure_password
> ```

## 🧪 Running Tests

The application includes comprehensive tests for models and controllers.

```bash
# Run all tests
bin/rails test

# Run model tests only
bin/rails test test/models

# Run controller tests only
bin/rails test test/controllers

# Run a specific test file
bin/rails test test/models/calculation_test.rb

# Run with verbose output
bin/rails test -v
```

## 🏗️ Technical Approach

### Architecture

This application follows standard Rails MVC architecture:

- **Model** (`Calculation`): Handles data validation, persistence, and business logic for tip calculations
- **Controllers**: 
  - `CalculationsController`: Manages the calculator form and saves calculations
  - `Admin::DashboardController`: Provides authenticated access to calculation history
- **Views**: ERB templates with responsive CSS and Stimulus.js for interactivity

### Database Design

```
calculations
├── id (bigint, primary key)
├── bill_amount (decimal, precision: 10, scale: 2)
├── tip_percentage (decimal, precision: 5, scale: 2)
├── tip_amount (decimal, precision: 10, scale: 2)
├── total_amount (decimal, precision: 10, scale: 2)
├── people_count (integer, default: 1)
├── per_person_amount (decimal, precision: 10, scale: 2)
├── created_at (datetime)
└── updated_at (datetime)

Indexes:
├── index_calculations_on_created_at
├── index_calculations_on_bill_amount
└── index_calculations_on_tip_percentage
```

### Key Technical Decisions

1. **Stimulus.js for Real-Time Updates**: Instead of making server round-trips for each input change, the calculator uses Stimulus.js for instant client-side calculations. The calculation is only saved to the database when the user clicks "Save".

2. **Custom Pagination**: Implemented a lightweight custom pagination instead of adding a gem like Kaminari or Pagy, keeping dependencies minimal for this project scope.

3. **Session-Based Authentication**: Implemented a custom styled login page with session-based authentication instead of browser HTTP Basic Auth dialogs. This provides better UX and allows for a branded login experience. Credentials are configurable via environment variables.

4. **Decimal Types with Precision**: Used `decimal(10,2)` for monetary values to avoid floating-point precision issues common with currency calculations.

5. **CSS Variables**: Utilized CSS custom properties for consistent theming and easy customization.

### File Structure

```
app/
├── assets/stylesheets/
│   └── application.css          # Complete responsive styles
├── controllers/
│   ├── calculations_controller.rb
│   └── admin/
│       ├── dashboard_controller.rb
│       └── sessions_controller.rb  # Login/logout handling
├── javascript/controllers/
│   └── tip_calculator_controller.js  # Stimulus controller
├── models/
│   └── calculation.rb           # Validations, scopes, statistics
└── views/
    ├── calculations/
    │   ├── new.html.erb         # Calculator form
    │   ├── result.html.erb      # Saved calculation view
    │   └── _result.html.erb     # Turbo Stream partial
    ├── admin/
    │   ├── dashboard/
    │   │   └── index.html.erb   # Admin dashboard
    │   └── sessions/
    │       └── new.html.erb     # Custom login page
    └── layouts/
        └── admin_login.html.erb # Login page layout
```

## 🚢 Deployment

### Environment Variables

Set these variables in your production environment:

```bash
RAILS_ENV=production
DATABASE_URL=postgres://user:password@host:port/database
SECRET_KEY_BASE=your_secret_key_base
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_secure_password
```

### Docker

The application includes a Dockerfile for containerized deployment:

```bash
# Build the image
docker build -t tip-calculator .

# Run the container
docker run -p 3000:3000 -e DATABASE_URL=... tip-calculator
```

### Heroku

```bash
heroku create your-tip-calculator
heroku addons:create heroku-postgresql:mini
heroku config:set ADMIN_USERNAME=admin ADMIN_PASSWORD=secure_password
git push heroku main
heroku run rails db:migrate
```

### Render / Railway / Fly.io

Each platform has similar setup requirements:
1. Connect your GitHub repository
2. Set environment variables
3. Configure PostgreSQL database
4. Deploy

## 📝 API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Tip calculator form (alias for `/calculations/new`) |
| GET | `/calculations/new` | Tip calculator form |
| POST | `/calculations` | Save a calculation |
| GET | `/admin/login` | Admin login page |
| POST | `/admin/login` | Authenticate admin |
| DELETE | `/admin/logout` | End admin session |
| GET | `/admin/dashboard` | Admin dashboard (protected) |

### POST `/calculations` (JSON)

Request:
```json
{
  "calculation": {
    "bill_amount": 100.00,
    "tip_percentage": 18.00,
    "people_count": 4
  }
}
```

Response (201 Created):
```json
{
  "id": 1,
  "bill_amount": 100.0,
  "tip_percentage": 18.0,
  "tip_amount": 18.0,
  "total_amount": 118.0,
  "people_count": 4,
  "per_person_amount": 29.5,
  "created_at": "2026-01-21T10:30:00.000Z"
}
```

## 🔒 Security Considerations

- Admin dashboard protected with session-based authentication
- Custom styled login page (not browser dialog)
- Strong parameters prevent mass assignment vulnerabilities
- Input validation on both client and server side
- CSRF protection enabled
- Content Security Policy headers configured
- No sensitive data stored in version control
- Credentials configurable via environment variables

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

Built with ❤️ using Ruby on Rails

