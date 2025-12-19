# 🚀 Admin Panel – Full‑Stack Ecommerce Management System

A **production‑ready admin dashboard** built to power modern ecommerce and service‑based applications. This panel provides **complete control over products, orders, staff, inventory, banners, discounts, ratings, and notifications**, all secured with **Supabase Row Level Security (RLS)** and implemented using **Flutter** for a clean, scalable UI.

This project was built end‑to‑end with real‑world constraints in mind  **not a demo**, not mock data  but a system ready to plug into a live client application.

---

## ✨ Key Highlights

* 🔐 **Secure by design** (Supabase RLS)
* 📦 **Full inventory & product lifecycle management**
* 🧑‍💼 **Staff & order assignment tracking**
* ⭐ **Order‑level ratings & feedback system**
* 📊 **Visual analytics dashboard**
* ⚡ **Real‑time data fetching**
* 🎨 **Modern dark‑themed admin UI**

---

## 🧭 Dashboard Overview

The dashboard gives admins instant insights at a glance:

* **Total Products Count**
* **Available Stock**
* **Limited Stock Alerts**
* **Out‑of‑Stock Products**
* **Stock Distribution Donut Chart** (Available / Limited / Out of Stock)

Designed for **clarity, speed, and decision‑making**.

---

## 🗂️ Core Modules & Features

### 🛒 Products

* Create, update, and delete products
* Manage pricing and images
* Stock status tracking (available, limited, out of stock)

### 🧩 Categories & Sub‑Categories

* Structured product organization
* Scalable category hierarchy

### 🏷️ Brands

* Brand creation and management
* Product‑to‑brand association

### 🔀 Variants & Variant Types

* Support for multiple product variations (e.g. size, color)
* Clean separation between variant types and values

### 🖼️ Banners

* Homepage promotional banners
* Dynamic banner updates from admin panel

### 💸 Discounts

* Create and manage discounts
* Ready for promotional campaigns

### ⭐ Ratings & Feedback

* **Order‑level rating system** (1–5 stars)
* Client comments stored securely
* Admin‑only visibility
* Staff attribution per order for performance insights

### 📦 Orders

* Full order lifecycle tracking
* Order status enforcement via database constraints
* Staff assignment per order
* Payment & delivery metadata support

### 🔔 Notifications

* Admin‑side notifications system
* Ready for real‑time or push integrations

---

## 🔐 Security Architecture (RLS)

This project heavily uses **Supabase Row Level Security**:

* Clients can **only insert ratings for their own orders**
* Admin users can **view all data across the system**
* No direct database access from UI widgets
* All reads handled via **service layers**

This ensures:

* ✅ Data isolation
* ✅ Zero data leakage
* ✅ Production‑grade access control

---

## 🏗️ Tech Stack

* **Flutter** – Admin UI
* **Supabase** – Backend (Postgres, Auth, RLS)
* **PostgreSQL** – Relational database
* **Supabase Storage** – Images & media
* **Service‑based architecture** – Clean data access
* **supabase edge function** – for notification

---

## 📁 Architecture Highlights

* Feature‑based folder structure
* Dedicated service classes for database access
* Strong model mapping for relational data
* UI completely decoupled from backend logic

This makes the project:

* Easy to maintain
* Easy to extend
* Easy to reuse for future clients

---

## 🎯 Use Cases

* Ecommerce admin dashboard
* Food delivery backend panel
* Inventory management system
* Multi‑vendor admin control panel
* Starter template for SaaS admin products

---

## 🧠 What This Project Demonstrates

* Real‑world database design
* Proper use of foreign keys & constraints
* Secure backend‑driven Flutter apps
* Admin UX best practices
* Scalable architecture for production systems

---

## 🚀 Status

✅ **Admin Panel Complete**
🛠️ Ready for client‑side app integration
📈 Ready for analytics & reporting extensions

---
<img width="1583" height="892" alt="dashboard_screen" src="https://github.com/user-attachments/assets/afd6d62d-9af9-4458-8db0-d2d3de813821" />
<img width="1595" height="892" alt="products_screen" src="https://github.com/user-attachments/assets/14a1d926-3017-4d2e-a3fd-e11d6c42141b" />
<img width="1604" height="892" alt="add_product_screen" src="https://github.com/user-attachments/assets/cd70de45-fb1f-4419-8415-a74fbdb22514" />
<img width="1596" height="892" alt="banners_screen" src="https://github.com/user-attachments/assets/cf8afa53-68f5-4fe9-b0db-32cdebeac822" />
<img width="1596" height="892" alt="settings_screen" src="https://github.com/user-attachments/assets/08e6d5a1-4394-4c1e-91c9-d06917fd6514" />
<img width="1592" height="892" alt="staff_management_screen" src="https://github.com/user-attachments/assets/345a933e-30ed-4184-b7d1-9a151895027a" />
<img width="1603" height="892" alt="staff_dashboard_screen" src="https://github.com/user-attachments/assets/60400a3e-63bf-496c-b578-ffca9576bff2" />
<img width="1624" height="892" alt="staff_settings_screen" src="https://github.com/user-attachments/assets/c5f76826-4c73-4fcb-bb46-4152156284db" />

## 🤝 Author

Built with care and production discipline by **Ernest Cheruiyot**.

> *This project reflects real‑world engineering decisions, not tutorial shortcuts.*

---
## 🔒 Source Code Notice

This public repository intentionally excludes core business logic,
backend service layers, and sensitive configuration files.

The purpose of this repository is to showcase:
- System architecture
- UI/UX design
- Database modeling approach
- Secure backend integration patterns

If you are interested in the **complete, production-ready version**
or would like this system customized for your business,
feel free to reach out.




⭐ If you find this useful or inspiring, feel free to star the repository!
