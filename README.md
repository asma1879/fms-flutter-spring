# Freelancing Management System (Flutter + Spring Boot + MySQL + Security)

A **freelancing platform** built with **Flutter** for the mobile frontend and **Spring Boot + MySQL + Security** for the backend.  
It allows clients and freelancers to connect, post jobs, place bids, manage payments, and communicate securely.  

---

## 📂 Project Structure

```
fms-flutter-spring/
│
├── freelance-system/ (Spring Boot + MySQL + Security)
│   ├── src/main/java/com/freelance/
│   │   ├── model/          # Entity classes
│   │   ├── dao/            # DAO interfaces
│   │   ├── impl/           # DAO implementations
│   │   ├── controller/     # Controllers (REST APIs)
│   │   ├── security/       # Spring Security configuration
│   │   └── FreelanceApplication.java
│   ├── src/main/resources/
│   │   ├── application.properties  # DB config
│   │  
│   └── pom.xml
│
├── freelance_app/ (Flutter)
│   ├── lib/
│   │   ├── models/         # Data models (Job, Bid, User, Message, Payment, etc.)
│   │   ├── services/       # API calls to backend
│   │   ├── screens/        # UI Screens (Login, Register, Dashboard, Wallet, etc.)
│   │   ├── providers/      # State management
│   │   └── main.dart       # App entry point
│   └── pubspec.yaml
│
└── README.md
```

---

## 🚀 Features

- User registration & login with **Spring Security & JWT**
- Role-based access (Client / Freelancer / System)
- Profile management
- Post & manage jobs
- Browse and apply to jobs
- Place and manage bids
- Wallet system
- **Secure escrow system** (funds held until job delivery)
- Add funds to wallet
- Withdraw funds with payment method and secure code
- Wallet transaction history
- Review & rating system
- Dashboard with charts (Flutter integration)


---

## ⚙️ Tech Stack

### Frontend (Mobile - Flutter)
- Flutter SDK
- Dart
- Provider / Riverpod for state management
- HTTP package for API requests
- SharedPreferences (for storing JWT tokens)
- Charts (for dashboard)
- Material UI components

### Backend (Spring Boot)
- Spring Boot (REST APIs)
- Spring Security + JWT
- Hibernate + JPA
- MySQL 8
- Maven

### Database
- MySQL 8
- ER Model includes: Users, Jobs, Bids, Messages, Payments, Wallet, Transactions

---

## ▶️ Run Backend (Spring Boot)

1. Open `backend/` in **Eclipse/IntelliJ**.
2. Configure `application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/freelance
   spring.datasource.username=root
   spring.datasource.password=root
   spring.jpa.hibernate.ddl-auto=update
   spring.jpa.show-sql=true
   spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

   # JWT Secret
   jwt.secret=your_jwt_secret_key
   ```
3. Run the project:
   ```bash
   mvn spring-boot:run
   ```
4. Backend will start at: **http://localhost:***

---

## ▶️ Run Frontend (Flutter)

1. Open `frontend/` in **VS Code / Android Studio**.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Update backend API URL inside `lib/services/api.dart`:
   ```dart
   class Api {
     static const String baseUrl = "http://10.0.2.2:8080/api"; // for Android emulator
     // Use http://localhost:8080/api if running Flutter web
   }
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 🔒 Security

- Spring Security with JWT authentication
- Role-based access control (Client / Freelancer / System)
- Passwords stored using **BCrypt hashing**
- Secured endpoints 
- Escrow & wallet operations require **authenticated user**

---


## 📜 License

This project is licensed under the MIT License.
