# Data-Driven Warehouse Management System (WMS) Optimization

## 📊 Project Overview
This project optimizes warehouse operations by analyzing product inventory velocity (demand) against physical 3D layout coordinates (Aisle, Section, Shelf). Using advanced SQL analytics, the system detects layout bottlenecks where high-demand items are stored in low-accessibility zones, increasing worker travel time and slowing order fulfillment.

## 📈 Key Achievements & Insights
* **Identified Operational Bottlenecks:** Found that out of 80 high-demand items, **22 critical items** (including high-volume parts like `SKU-5005` and `SKU-1001`) were mistakenly slotted in Aisle 10 on Top Shelf Levels (Level 5)—the absolute furthest physical distance from the shipping docks.
* **Designed a Re-Slotting Action Plan:** Generated a dynamic algorithmic relocation strategy prioritizing ground-level slots in Aisles 1 & 2 for high-velocity goods.
* **Quantified Business ROI:** Modeled a **32.57% reduction in warehouse labor and travel friction** upon executing the re-slotting plan, drastically improving picking cycle speeds.

## 🛠️ Tech Stack & Skills Demonstrated
* **Database:** SQLite
* **SQL Concepts:** Multi-table `JOIN` operations, conditional logic (`CASE WHEN`), date arithmetic (`julianday()`), string parsing (`SUBSTR`), data aggregations (`SUM`, `COUNT`).
* **Analytics Framework:** ABC Inventory Analysis / Slotting Optimization.