import pandas as pd
from hdfs import InsecureClient
from io import BytesIO
import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def map_reduce_hdfs_analysis():
    client = InsecureClient('http://namenode:9870', user='root')
    root_path = '/analytics/supply_chain'
    
    # --- STEP 1: MAPPING (Recursive Discovery) ---
    logger.info(f"Mapping files in {root_path}...")
    
    all_shards = []
    
    # walk() yields (dirpath, dirnames, filenames)
    for root, dirs, files in client.walk(root_path):
        for file in files:
            if file.endswith('.parquet'):
                full_path = f"{root}/{file}"
                logger.info(f"Mapping shard: {full_path}")
                
                # Each 'read' here represents a Map task on a data block
                with client.read(full_path) as reader:
                    shard_data = pd.read_parquet(BytesIO(reader.read()))
                    all_shards.append(shard_data)

    if not all_shards:
        logger.warning("No Parquet shards found. Check your HDFS paths.")
        return

    # --- STEP 2: SHUFFLE & REDUCE (Concatenation & Aggregation) ---
    logger.info("Reducing shards into global dataframe...")
    full_df = pd.concat(all_shards, ignore_index=True)
    
    # Perform analytical "Reduce" operation
    # Calculating Weighted Average Profit Ratio per Category
    analytics_results = full_df.groupby('Category_Name').agg({
        'Sales': 'sum',
        'Order_Item_Profit_Ratio': 'mean',
        'Days_for_shipping_real': 'mean'
    }).rename(columns={
        'Order_Item_Profit_Ratio': 'Avg_Profit_Ratio',
        'Days_for_shipping_real': 'Avg_Actual_Shipping_Days'
    }).reset_index()

    # --- STEP 3: OUTPUT ---
    logger.info("Final reduction complete. Sample results:")
    print(analytics_results.head())

    # Write the 'Gold' summary back to HDFS
    output_path = '/analytics/gold/category_performance.parquet'
    client.makedirs('/analytics/gold')
    with BytesIO() as buffer:
        analytics_results.to_parquet(buffer, index=False)
        buffer.seek(0)
        client.write(output_path, buffer.read(), overwrite=True)

if __name__ == "__main__":
    map_reduce_hdfs_analysis()
