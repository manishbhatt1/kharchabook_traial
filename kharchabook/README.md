# KharchaBook

Personal finance tracker (Java Servlet + JSP + JDBC + MySQL) for **CS5054NT — Advanced Programming and Technologies**.

## Prerequisites

- **JDK 11+**
- **Apache Tomcat 9.x** (uses `javax.servlet`; for Tomcat 10+ you would migrate to Jakarta EE package names)
- **MySQL 8** (XAMPP MySQL is fine)
- **Maven 3.8+** (bundled with IntelliJ IDEA Ultimate / available as plugin)

## Database setup

1. Start MySQL and create the schema (adjust path):

   ```text
   mysql -u root -p < sql/schema.sql
   ```

2. Edit `src/main/resources/db.properties` with your MySQL username and password (default XAMPP is often `root` with an empty password).

## Default admin account

| Field | Value |
|--------|--------|
| Email | `admin@kharchabook.com` |
| Password | `admin123` |

Passwords are stored as **SHA-256** hex digests, as required by the module brief.

## IntelliJ IDEA

1. **File → Open** and select the `kharchabook` folder (the one that contains `pom.xml`).
2. Import as a **Maven** project and wait for dependencies (Servlet API, JSTL, MySQL driver).
3. **Build → Build Project** (or `mvn clean package`).
4. Add a **Tomcat** run configuration:
   - **Edit Configurations → + → Tomcat Server → Local**
   - **Deployment** tab: add artifact **`kharchabook:war exploded`** (or `kharchabook:war`)
   - Set **Application context** to `/kharchabook` (or `/` if you prefer the root context)
5. Run. Open: `http://localhost:8080/kharchabook/` (adjust port/context if you changed them).

## Project layout

- `src/main/java/com/kharchabook/` — servlets (controllers), JDBC DAOs, filters, utilities
- `src/main/webapp/` — JSP views, CSS (`css/style.css`), `WEB-INF/web.xml`
- `sql/schema.sql` — database and seed data (Nepal categories + sample tips)

## Features implemented

- User registration (pending until admin approves), login, session-based auth, SHA-256 passwords  
- Role separation: **USER** vs **ADMIN** (filters on `/user/*` and `/admin/*`)  
- Transactions, budgets with progress and 80% / over-budget alerts, savings goals, tips + wishlist  
- Admin: users, categories, tips, dashboards and reports  

## Team

L2C1 Boys — London Met CS5054NT
