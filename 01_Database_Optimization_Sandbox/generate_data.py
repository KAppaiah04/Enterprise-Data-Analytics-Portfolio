import sqlite3
import random
from datetime import datetime, timedelta

#connecting to local sql database
conn = sqlite3.connect ('wms_sandbox.db')
cursor = conn.cursor()

print ("Populating warehouse location...")
#generating warehouse location(zones A to D, 10 Aisle, 5 levels)
zones = ['A','B','C','D']
locations = []

for zone in zones:
    for aisle in range (1,11):
        for level in range(1,6):
            loc_code = f"{zone}-{aisle:02d}-{level}"
            locations.append ((loc_code,zone,aisle,level))


#inserting locations 

cursor.executemany ( ''' insert or ignore into warehouse_locations (location_code, zone, aisle_number, shelf_level)
                    values (?,?,?,?)''', locations )


print ("Popukating intial incventory stock...")
#generating mock inventory item

sample_items = [
    ('SKU-1001', 'High-Density Widget'),
    ('SKU-2002', 'Premium Alpha Component'),
    ('SKU-3003', 'Standard Eco-Brace'),
    ('SKU-4004', 'Heavy Duty Fastener'),
    ('SKU-5005', "Precision Calibration Sensor")
]

inventory_rows =[]
start_date = datetime.now()- timedelta(days=30)

#creating 500 intial stock records distributed acorss random locations
for i in range (500):
    sku,desc = random.choice(sample_items)
    qty = random.randint(10,500)
    loc = random.choice(locations)[0] # grabbing random location_code
    rec_date = (start_date + timedelta(days=random.randint(0,30))).strftime('%Y-%m-%d')

    inventory_rows.append((sku,desc,qty,loc,rec_date))

cursor.executemany (''' insert or ignore into inventory_stock (sku, item_description, quantity, location_code, date_recived)
                    values (?,?,?,?,?)''', inventory_rows)

#commit the changes and close the connection
conn.commit()
conn.close()

print ("Successfully injected mock data into sandbox db")