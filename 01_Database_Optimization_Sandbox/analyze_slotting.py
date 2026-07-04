import sqlite3
import pandas as pd
import os

def run_slotting_pipeline():
    database_name = 'wms_sandbox.db'
    output_csv= 'critical_relocation_manifest.csv'

    print ("Starting Automated Warehouse Slotting Optimization Pipeline...")

    # Establshing secure connection to SQL database
    if not os.path.exists(database_name):
        print (f"Error: Database File {database_name} not found. Please ensure it exists in directory")
        return
    
    conn = sqlite3.connect(database_name)

    # Define optimised query

    query = """
        SELECT
            i.sku,
            i.item_description,
            i.location_code as current_location,
            w.aisle_number as current_aisle,
            w.shelf_level as current_aisle
            (w.aisle_number * 3) + (w.shelf_level * 5) as current_difficluty_score,
            CASE
                WHEN (w.aisle_number * 3) + (w.shelf_level *5) >=40 THEN ' Critical Action - Relocate to Aisle 01 or 02 (Ground level)'
                WHEN (w.aisle_number * 3) + (w.shelf_level *5) >=25 THEN ' Recommend : Move to Mid_Aisle (Shelf 1-2)'
                ELSE 'OK: Leave in Current Optimal Position'
            END as operational_action_plan
            FROM
            inventory_stock i
            JOIN warehouse_locations w on i.location_code = w.location_code
            WHERE (julianday('now') - julianday(i.date_recived)) <=7
            ORDER BY current_difficulty_score DESC;
    """

    try:

        # Read SQL data straight into pandas dataframe
        print ("Extracting inventory demand metrics and analyzing physical layout constraints...")
        df= pd.read_sql_query(query,conn)

        #filter down to *only* the operational item reqiuring immediate warehouse interventions
        critical_df = df[df['operational_action_plan'].str.contains('Critical Action')]

        #Export results into actionable csv manifest for fullfillment teams
        if not critical_df.empty:
            critical_df.to_csv( output_csv, index=False)
            print (f"Success! Generated '{output_csv}' with {len(critical_df)} optimized updates")
            print (f"Action Item : Share this file with Floor Operations team to execute re-slotting")
        else:
            print (f"Optimization Completed : NO critical slotting bottlenecks found Today!")

    except Exception as e:
        print (f"Pipleine Failed error :{e}")

    finally:
        #Saftey closing the database connections
        conn.close()
        print ("Pipeline exection is completed successfully")


if __name__ =='__main__':
    run_slotting_pipeline()

                  
