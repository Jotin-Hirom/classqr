Backend run:
- cd backend
- npm src/server.js 
  or
- npx nodemon src/server.js
  or
- npm run dev

FrontEnd run:
cd frontend
flutter run -d chrome

or

- Go to run
- Select start debugging


//Import difference
Curly braces {} → Named export
No curly braces → Default export

//Difference
.env holds project-level settings,
local.env holds your personal settings.

.env → development
.env.production → deployment
.env.test → testing


# Folder Structure:
| Folder           | Why it exists                           |
| ---------------- | --------------------------------------- |
| controllers/     | Handles requests, calls services        |
| models/          | Data representation & DB structure      |
| middlewares/     | Authentication, validation, permissions |
| routes/          | Defines API endpoints                   |
| services/        | Main business logic                     |
| utils/           | Helper functions (reusable)             |
| config/          | Testing database                        |
| schema/          | Database Schema                         |

Backend:
/src
 ├── config
 │    ├── initdb.js
 │    └── pool.js
 │    └── testdb.js
 │
 ├── schema
 │    └── schemaPostgre.sql
 │
 ├── models
 │    ├── user.model.js
 │    ├── student.model.js
 │    ├── teacher.model.js
 │    ├── subject.model.js
 │    ├── courseOffering.model.js
 │    ├── studentEnrollment.model.js
 │    ├── qrSession.model.js
 │    ├── scanEvent.model.js
 │    ├── attendance.model.js
 │    ├── verificationLog.model.js
 │    ├── report.model.js
 │    ├── refreshToken.model.js
 │
 ├── services
 │    ├── auth.service.js
 │    ├── user.service.js
 │    ├── student.service.js
 │    ├── teacher.service.js
 │    ├── subject.service.js
 │    ├── course.service.js
 │    ├── qr.service.js
 │    ├── attendance.service.js
 │    ├── report.service.js
 │    ├── otp.service.js
 │
 ├── controllers
 │    ├── auth.controller.js
 │    ├── user.controller.js
 │    ├── student.controller.js
 │    ├── teacher.controller.js
 │    ├── subject.controller.js
 │    ├── course.controller.js
 │    ├── qr.controller.js
 │    ├── attendance.controller.js
 │    ├── report.controller.js
 │
 ├── routes
 │    ├── auth.routes.js
 │    ├── user.routes.js
 │    ├── student.routes.js
 │    ├── teacher.routes.js
 │    ├── subject.routes.js
 │    ├── course.routes.js
 │    ├── qr.routes.js
 │    ├── attendance.routes.js
 │    ├── report.routes.js
 │
 ├── middlewares
 │    ├── auth.middleware.js
 │    ├── role.middleware.js
 │    ├── error.middleware.js
 │
 ├── utils
 │    ├── jwt.js
 │    ├── password.js
 │    ├── responses.js
 │    ├── deviceFingerprint.js
 │    ├── subjects.js
 │    ├── mailer.js
 │    ├── otp.js
 │    ├── validator.js
 |
 |
 ├── app.js
 ├── server.js
 └── package.json

FrontEnd:
 /lib
├── main.dart
├── app.dart                         # MaterialApp, routes, theme, navigation
│
├── core/
│   ├── config/
│   │    └── env.dart                # Base URLs, env variables
│   │
│   ├── constants/
│   │    ├── colors.dart
│   │    ├── text_styles.dart
│   │    ├── app_padding.dart
│   │    ├── api_endpoints.dart
│   │    └── assets.dart
│   │
│   ├── utils/
│   │    ├── validators.dart         # All validation rules (roll, password…)
│   │    ├── extensions.dart
│   │    ├── helpers.dart
│   │    ├── device_fingerprint.dart
│   │    └── secure_storage.dart     # For tokens if needed
│   │
│   ├── services/
│   │    ├── api_service.dart        # Core HTTP client
│   │    ├── auth_service.dart
│   │    ├── student_service.dart
│   │    ├── teacher_service.dart
│   │    ├── course_service.dart
│   │    ├── attendance_service.dart
│   │    ├── qr_service.dart
│   │    └── admin_service.dart
│   │
│   └── errors/
│        ├── api_error.dart
│        ├── exception_handler.dart
│        └── error_messages.dart
│
├── models/
│   ├── user.dart
│   ├── student.dart
│   ├── teacher.dart
│   ├── subject.dart
│   ├── course.dart
│   ├── attendance.dart
│   ├── qr_session.dart
│   ├── scan_event.dart
│   ├── admin.dart
│   └── report.dart
│
├── viewmodels/                      # MVVM (logic/controllers)
│   ├── auth_viewmodel.dart
│   ├── student_dashboard_viewmodel.dart
│   ├── teacher_dashboard_viewmodel.dart
│   ├── course_viewmodel.dart
│   ├── attendance_viewmodel.dart
│   ├── scanner_viewmodel.dart
│   ├── admin_viewmodel.dart
│   └── profile_viewmodel.dart
│
├── providers/                       # Riverpod providers ONLY
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── student_provider.dart
│   ├── teacher_provider.dart
│   ├── course_provider.dart
│   ├── attendance_provider.dart
│   ├── qr_provider.dart
│   ├── admin_provider.dart
│   └── theme_provider.dart
│
├── views/                           # UI screens grouped by roles & features
│   ├── auth/
│   │    ├── auth_page.dart
│   │    └── widgets/
│   │         ├── signup_form.dart
│   │         ├── signin_form.dart
│   │         └── forgot_form.dart
│   │
│   ├── student/
│   │    ├── student_dashboard_page.dart
│   │    ├── attendance_calendar_page.dart
│   │    ├── attendance_detail_page.dart
│   │    ├── profile_completion_page.dart
│   │    └── widgets/
│   │         ├── attendance_tile.dart
│   │         └── calendar_cell.dart
│   │
│   ├── teacher/
│   │    ├── teacher_dashboard_page.dart
│   │    ├── course_list_page.dart
│   │    ├── course_details_page.dart
│   │    ├── take_attendance_page.dart
│   │    ├── add_course_page.dart
│   │    ├── student_list_page.dart
│   │    └── widgets/
│   │         ├── course_card.dart
│   │         ├── student_row.dart
│   │         └── attendance_summary_card.dart
│   │
│   ├── qr/
│   │    ├── qr_scanner_page.dart
│   │    └── qr_display_page.dart       # Teacher's QR generator page
│   │
│   ├── admin/
│   │    ├── admin_dashboard_page.dart
│   │    ├── user_list_page.dart
│   │    ├── system_logs_page.dart
│   │    ├── ml_anomaly_page.dart
│   │    └── widgets/
│   │         ├── admin_card.dart
│   │         └── log_tile.dart
│   │
│   └── common/
│        ├── splash_page.dart
│        ├── home_selector_page.dart    # Selects student/teacher/admin dashboard
│        ├── error_page.dart
│        ├── loading_page.dart
│        └── no_data.dart
│
├── widgets/
│   ├── m3_input_field.dart
│   ├── primary_button.dart
│   ├── card_tile.dart
│   ├── app_logo.dart
│   ├── snackbars.dart
│   ├── empty_state.dart
│   ├── loading_indicator.dart
│   └── dialog_box.dart
│
└── theme/
    ├── theme.dart                    # Material 3 theme (light/dark)
    └── palette.dart                  # Extended colors


# Use this command for creating folders with files at same time :
mkdir config, schema, models, services, controllers, routes, middlewares, utils
ni config/initdb.js, config/pool.js, config/testdb.js
ni schema/schemaPostgre.sql
ni models/user.model.js, models/student.model.js, models/teacher.model.js, models/subject.model.js, models/courseOffering.model.js, models/studentEnrollment.model.js, models/qrSession.model.js, models/scanEvent.model.js, models/attendance.model.js, models/verificationLog.model.js, models/report.model.js, models/refreshToken.model.js
ni services/auth.service.js, services/user.service.js, services/student.service.js, services/teacher.service.js, services/subject.service.js, services/course.service.js, services/qr.service.js, services/attendance.service.js, services/report.service.js, services/otp.service.js
ni controllers/auth.controller.js, controllers/user.controller.js, controllers/student.controller.js, controllers/teacher.controller.js, controllers/subject.controller.js, controllers/course.controller.js, controllers/qr.controller.js, controllers/attendance.controller.js, controllers/report.controller.js
ni routes/auth.routes.js, routes/user.routes.js, routes/student.routes.js, routes/teacher.routes.js, routes/subject.routes.js, routes/course.routes.js, routes/qr.routes.js, routes/attendance.routes.js, routes/report.routes.js
ni middlewares/auth.middleware.js, middlewares/role.middleware.js, middlewares/error.middleware.js
ni utils/jwt.js, utils/password.js, utils/responses.js, utils/deviceFingerprint.js, utils/subjects.js, utils/mailer.js, utils/otp.js, utils/validator.js
ni app.js

Explanation:
mkdir (or New-Item -ItemType Directory) creates multiple folders separated by commas.
ni (short for New-Item) creates files.
-ItemType File ensures they are empty files.


powershell: Remove-Item -Recurse -Force .git
Explanation:
-Recurse → removes everything inside the .git folder
-Force → deletes hidden items without prompting
.git → the hidden folder that stores Git history
After that, you can reinitialize Git cleanly:
git init
git add .
git commit -m "Restart project from scratch"
git remote add origin https://github.com/<your-username>/<repo-name>.git
git branch -M main
git push --force origin main /git push


If you only want to remove sensitive data or files from the current repo and push again, do this:
git rm --cached local.env
git commit -m "Remove local.env from repo"
git push


TypeError: Cannot read properties of undefined (reading 'release')
//Client issue in Database. Fix in Pool.


//Creating JWT_SECRET
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
jwt.sign(payload, process.env.JWT_SECRET)


JWT_SECRET
Used to sign access tokens (the token you send in Authorization: Bearer xyz).
Characteristics:
Short-lived (15m, 10m, 30m)
Sent with every request to backend
Validates normal requests (dashboard, API calls, profile access)
If leaked, attacker can impersonate user only until token expires

REFRESH_SECRET
Used to sign refresh tokens, which allow users to stay logged-in without typing password again.
Characteristics:
Long-lived (7d, 30d, 90d)
Stored in HttpOnly cookies
NEVER exposed to JavaScript
Used only to issue new access tokens
If leaked, attacker can generate infinite access tokens until it expires


# JOIN:
INNER JOIN (only matching rows)
LEFT JOIN (all users, students if exist)
RIGHT JOIN (all students, users if exist)
FULL JOIN (all rows from both tables)


| Token       | Purpose        | Lifetime  |
| ----------- | -------------- | --------- |
| **Access**  | API access     | 10–15 min |
| **Refresh** | get new access | 7–30 days |
Example Flow:
1. User logs in → gets
   * accessToken (short life)
   * refreshToken (long life)
2. User uses accessToken normally.
3. After 15 min, accessToken expires.
4. Frontend calls:
   `POST /auth/refresh`
5. Backend verifies refreshToken.
6. Backend creates:
   * new accessToken
   * new refreshToken (rotation)
7. Frontend updates tokens silently.

Note: User does NOT login again.

#When should you NOT use refresh tokens?

Refresh tokens **should NOT be sent to other endpoints.**
They should not be used to:

* authenticate user
* validate login
* access APIs
* store user info

# 6. Where do you store refresh tokens?
 In **HTTP-only secure cookies**
* Browser can't read it
* JS can't steal it
* Protected from XSS
* Sent automatically to `/auth/refresh` only

Do NOT store in localStorage/sessionStorage
Do NOT expose to JavaScript
Do NOT send refresh token in headers

### When user hits `/auth/refresh`:
1. Backend receives refresh token from cookie.
2. Hash it.
3. Check in DB:
   * valid?
   * not expired?
   * not revoked?
4. If valid:
   * revoke old refresh token
   * generate new refresh + access token
   * store new refresh hash
5. Send back:
   * accessToken (JSON)
   * refreshToken via new cookie

This is **token rotation** (strongest security).


### When attacker steals a refresh token:
* rotation will catch theft
* system revokes all tokens
* forces full re-login


| Thing                 | Meaning                                             |
| --------------------- | --------------------------------------------------- |
| Access Token          | short life (10–15 min), used for APIs               |
| Refresh Token         | long life (7–30 days), only for creating new access |
| Where stored?         | HTTP-only cookies                                   |
| When used?            | only when access token expires                      |
| Why rotate?           | prevent stolen token replay                         |
| Why store hash in DB? | can't steal refresh tokens even if DB leaks         |


Error:Invalid character in header content ["Host"]
This always happens when your URL contains spaces, line breaks, or illegal characters.



FRONTEND :

Failed to Hot Restart: DebugAdapterException: Invalid argument(s): Uri org-dartlang-app:/web_plugin_registrant.dart must have scheme 'file:'.
Fixed by: 
flutter clean
flutter pub get
flutter clean
flutter pub get
