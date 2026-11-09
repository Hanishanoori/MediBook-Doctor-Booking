# MediBook - Doctor Appointment Booking Website

A full-stack appointment booking system with live queue tokens.

| Layer    | Technology                                                                 |
|----------|----------------------------------------------------------------------------|
| Frontend | HTML5, CSS3, JavaScript, React 18 (Vite dev server, React Router)          |
| Backend  | Java, Spring Boot 3.5 (REST API, Spring Data JPA, Bean Validation)         |
| Database | H2 embedded file database - nothing to install, no MySQL or Oracle needed  |

Node.js and npm are used **only** as development tools (installing React and running the Vite dev server).
The backend is 100% Java / Spring Boot.

---

## Quick start on Windows 11 (Command Prompt)

### 1. Install the prerequisites once

| Tool | Version | Check it with |
|------|---------|---------------|
| JDK (not just a JRE) | 17 or newer. **Java 25 is supported.** | `java -version` and `javac -version` |
| Node.js (includes npm) | 18 or newer - 22 LTS recommended | `node -v` and `npm -v` |

You do **not** need to install Maven: the project includes the Maven Wrapper (`mvnw.cmd`), which downloads
Maven automatically the first time. You also do **not** need MySQL.
The first run needs an internet connection (Maven + npm downloads).

If `java` or `javac` is "not recognized", install a JDK, make sure its `bin` folder is on `PATH`
(or set `JAVA_HOME`), and open a **new** Command Prompt.

### 2. Start the app

**Easiest:** double-click `start-all.bat` in the project folder. It opens one window for the backend and one
for the frontend. Wait until the backend window shows `Started MediBookApplication`, then open
**http://localhost:5173**.

**Or run the two parts yourself** in two separate Command Prompt windows
(replace the path with wherever you extracted the project):

Window 1 - backend:

```bat
cd C:\path\to\medibook\backend
mvnw.cmd spring-boot:run
```

Window 2 - frontend:

```bat
cd C:\path\to\medibook\frontend
npm install
npm run dev
```

Stop either part with `Ctrl+C`.

### 3. Local URLs

| What | URL |
|------|-----|
| The website (open this one) | http://localhost:5173 |
| Backend REST API | http://localhost:8080/api/doctors |
| H2 database console (optional) | http://localhost:8080/h2-console - JDBC URL `jdbc:h2:file:./data/medibook`, user `sa`, empty password |
| Production-build preview (after `npm run build`) | http://localhost:4173 |

### 4. First-run check

1. Open http://localhost:8080/api/doctors - you should see JSON for 10 demo doctors.
2. Open http://localhost:5173 - the home page should list doctors.
3. Log in with a demo account (below), book an appointment, then log in as admin and "Call in" the token.

### Demo accounts (created automatically on first start)

| Role | Email | Password |
|------|-------|----------|
| Admin   | `admin@medibook.com`   | `Admin@123`   |
| Patient | `patient@medibook.com` | `Patient@123` |

plus 10 demo doctors (cardiology, dermatology, pediatrics, ...) with weekly schedules.
These are demo credentials for local use only. Set `app.seed-demo-data=false` to skip the demo doctors and
patient (the admin account is always created) and change `app.admin.password` / `APP_SECRET` before any real deployment.

---

## Building and checking

Run these from Command Prompt:

```bat
:: Backend - compile and package a runnable jar
cd C:\path\to\medibook\backend
mvnw.cmd clean package
java -jar target\medibook-backend-1.0.0.jar

:: Frontend - production build, then preview it on port 4173
cd C:\path\to\medibook\frontend
npm install
npm run build
npm run preview
```

The project currently contains no automated backend tests, so `mvnw.cmd clean package` only compiles and packages.

## Database (H2)

- The data lives in `backend\data\medibook.mv.db`, created automatically on first start. Tables are created by
  Hibernate (`spring.jpa.hibernate.ddl-auto=update`), so there is no SQL script to run.
- **Reset all data:** stop the backend, delete the `backend\data` folder, start again.
- Data survives restarts. Only one backend instance can use the database file at a time; if a previous run was
  killed and the next start complains about a lock, wait a few seconds or delete `backend\data\medibook.lock.db`.

## How the frontend talks to the backend

During development the Vite server (port 5173) forwards every `/api/...` request to the Spring Boot backend at
`http://127.0.0.1:8080` (see `frontend/vite.config.js`), so the browser only ever talks to port 5173.
The backend also has CORS enabled for `http://localhost:*` and `http://127.0.0.1:*`
(`app.cors.allowed-origins`), which covers opening the site via either address.

To host the built frontend somewhere else, set `VITE_API_URL` (see `frontend/.env.example`) to the backend address
before running `npm run build`, and add the site's origin to `app.cors.allowed-origins`.
To point the dev proxy at a different backend address, set the `VITE_BACKEND_URL` environment variable.

## Features

**Patients**
- Home page, doctor listing with specialization, availability days, experience and consultation fee
- Search by name/specialization and filter by specialization and hospital
- Doctor profile with weekly schedule
- Booking: pick a date (next 60 days) and a time slot; taken or passed slots are disabled
- Automatic token number per doctor per day, booking reference, confirmation ticket (printable)
- Live token tracking: now serving, patients ahead, estimated wait (auto-refresh every 8 s)
- Appointment history (upcoming / past), cancel before your turn
- Registration, login, profile management and password change

**Admin**
- Overview: today's appointments, waiting count, doctors, patients, status breakdown
- Appointments: filter by date / doctor / status; call a patient in, complete, mark missed, cancel
- Doctors: add, edit, activate / deactivate
- Schedules: weekly shifts per doctor (several shifts per day, slot length per shift)
- Patients list with search

## How tokens work

- A token is issued the moment a booking is confirmed: `highest token for that doctor on that date + 1`.
  Numbers are never reused on a day, even after cancellations.
- Status flow: **Waiting -> With doctor -> Completed** (or **Cancelled / Missed**).
- When the admin presses **Call in**, that token becomes *now serving*; any previous patient still marked
  "With doctor" for the same doctor is completed automatically.
- *Patients ahead* = waiting or in-consultation tokens with a lower number for the same doctor and date.
  *Estimated wait* = patients ahead x the slot length of that day's shift.
- Bookings are serialised on the server, so two patients cannot receive the same slot or token.

## Validation rules (frontend and backend)

- Email format; password 8+ characters with letters and numbers; phone 10-15 digits
- Dates: no past dates, at most 60 days ahead; times must exist in the doctor's schedule
- One active appointment per patient / doctor / day; a slot can only be booked once
- Admin: required doctor fields, fee 0-100000, experience 0-70, shifts must not overlap, start before end

## REST API summary

| Method | Path | Access |
|--------|------|--------|
| POST | `/api/auth/register`, `/api/auth/login` | public |
| GET | `/api/doctors?q=&specialization=&hospital=` | public |
| GET | `/api/doctors/filters`, `/api/doctors/{id}`, `/api/doctors/{id}/slots?date=YYYY-MM-DD` | public |
| GET / PUT | `/api/me`, `/api/me/password` | logged in |
| POST | `/api/appointments` | logged in |
| GET | `/api/appointments/my`, `/api/appointments/{id}`, `/api/appointments/{id}/track` | logged in (own) |
| PUT | `/api/appointments/{id}/cancel` | logged in (own) |
| GET | `/api/admin/stats`, `/api/admin/patients`, `/api/admin/doctors`, `/api/admin/appointments?date=&doctorId=&status=` | admin |
| POST / PUT | `/api/admin/doctors`, `/api/admin/doctors/{id}` | admin |
| PUT | `/api/admin/doctors/{id}/schedules`, `/api/admin/appointments/{id}/status` | admin |

Authentication uses a signed bearer token (HMAC-SHA256, 24 h) sent in the `Authorization` header. Passwords are
stored with BCrypt.

## Project structure

```
medibook/
├── README.md
├── start-all.bat, start-backend.bat, start-frontend.bat      Windows launchers
├── backend/                            Spring Boot (Maven, includes mvnw.cmd wrapper)
│   ├── pom.xml
│   ├── mvnw.cmd, mvnw, .mvn/wrapper/   Maven Wrapper - no Maven install needed
│   └── src/main/
│       ├── resources/                  application.properties (H2 configuration)
│       └── java/com/medibook/
│           ├── MediBookApplication.java
│           ├── config/                 AppConfig, WebConfig (CORS + auth interceptor), DataSeeder
│           ├── security/               TokenService, AuthInterceptor
│           ├── model/                  User, Doctor, Schedule, Appointment, enums
│           ├── repository/             Spring Data JPA repositories
│           ├── dto/                    Request/response records, Mapper
│           ├── service/                Auth, Doctor, Appointment, Admin business logic
│           ├── controller/             REST controllers
│           └── exception/              ApiException, GlobalExceptionHandler
└── frontend/                           React (Vite)
    ├── package.json, package-lock.json, vite.config.js, index.html
    └── src/
        ├── main.jsx, App.jsx, api.js, AuthContext.jsx, Toast.jsx, utils.js, styles.css
        ├── components/                 Navbar, Footer, DoctorCard, Ticket, Modal, ...
        └── pages/                      Home, Doctors, DoctorDetail, Book, Confirmation,
                                        MyAppointments, TrackToken, Login, Register, Profile,
                                        admin/ (Dashboard, Appointments, Doctors, Patients)
```

## Configuration

Everything is in `backend/src/main/resources/application.properties`:

| Property | Purpose |
|----------|---------|
| `spring.datasource.url` | H2 database file location (default `jdbc:h2:file:./data/medibook`) |
| `app.timezone` | Clock used for "today" and slot cut-offs (default `Asia/Kolkata`) |
| `app.security.secret` | Token signing key. **Change it** (or set the `APP_SECRET` environment variable) before deploying |
| `app.admin.email` / `app.admin.password` | Seeded admin login |
| `app.cors.allowed-origins` | Origin patterns allowed to call the API directly |
| `app.seed-demo-data` | Create demo doctors and patient on first start |

## Troubleshooting

| Problem | What to do |
|---------|------------|
| `'java' is not recognized` | Install a JDK 17+ and open a **new** Command Prompt. Check with `java -version`. |
| `No compiler is provided in this environment` | You have a JRE, not a JDK. Install a full JDK and make sure `JAVA_HOME` (if set) points to it. |
| `'npm' is not recognized` | Install Node.js 18+ from nodejs.org and open a **new** Command Prompt. |
| Browser shows "Cannot reach the server" | The backend is not running (or still starting). Check the backend window for `Started MediBookApplication`. |
| `Port 8080 was already in use` | Find the process: `netstat -ano \| findstr :8080`, then `taskkill /PID <pid> /F`. Or change `server.port` in `application.properties` and set `VITE_BACKEND_URL` for the frontend. |
| `Port 5173 is already in use` | Close the other Vite window, or free the port the same way (`findstr :5173`). |
| `mvnw.cmd` cannot download Maven | Needs internet access to repo.maven.apache.org. Behind a corporate proxy, configure the proxy in `%USERPROFILE%\.m2\settings.xml` or install Maven yourself and run `mvn spring-boot:run`. |
| H2 "database may be already in use" | Another backend instance is running, or a previous run was killed. Close it, or delete `backend\data\medibook.lock.db`. |
| Slots show "doctor is off" | The doctor has no shift for that weekday - add one under Admin > Doctors > Schedule. |

## Notes

This is a learning/demo project. Payment is collected at the hospital counter (no online payment), and there are
no email/SMS notifications. For production add HTTPS, a strong `APP_SECRET`, a production database, and replace
`ddl-auto=update` with managed migrations.

Version notes: the backend uses Spring Boot 3.5.16 (Java 25 compatible; this is the last open-source release of the
3.5 line, so plan an upgrade to Spring Boot 4.x for long-term use). The frontend keeps React Router 6; `npm audit`
reports two moderate advisories for it whose fix is only available in React Router 7 (a major upgrade) and which affect
server-side rendering and unvalidated redirect targets that this client-only app does not use.
