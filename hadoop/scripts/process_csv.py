import pandas as pd
from hdfs import InsecureClient
from io import BytesIO
import logging

# Setup logging for the 'Software Engineer' touch
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def run_hdfs_pipeline():
    # 1. Connect to HDFS
    # Since we are inside the 'apps' container, use the service name 'namenode'
    client = InsecureClient('http://namenode:9870', user='root')
    
    local_path = '/src/data/supply_chain.csv' # Adjust filename as needed
    hdfs_dest_folder = '/analytics/supply_chain'
    
    try:
        # 2. Load and Prepare Data
        logger.info("Reading local CSV...")
        df = pd.read_csv(local_path, encoding='ISO-8859-1')

        # Convert date columns to datetime objects
        date_cols = ['order_date_DateOrders', 'shipping_date_DateOrders']
        for col in date_cols:
            df[col] = pd.to_datetime(df[col])

        # 3. Complex Transformation: Create a 'Late_Shipping_Margin'
        # Useful for your future forecasting tasks
        df['Shipping_Diff'] = (df['Days_for_shipping_real'] - df['Days_for _shipment_scheduled'])
        
        # 4. HDFS Partitioning Strategy
        # Instead of one big file, we'll write by 'Market' to show HDFS organization
        markets = df['Market'].unique()
        
        for market in markets:
            market_slug = market.lower().replace(' ', '_')
            market_df = df[df['Market'] == market]
            
            # Define HDFS path
            hdfs_path = f"{hdfs_dest_folder}/market={market_slug}/data.parquet"
            
            # Create folder if it doesn't exist
            client.makedirs(f"{hdfs_dest_folder}/market={market_slug}")

            # 5. Atomic Write to HDFS using Parquet (Better for Power BI/Big Data)
            logger.info(f"Writing {market} data to HDFS at {hdfs_path}...")
            
            # Use a buffer to avoid writing temporary files to the container's disk
            with BytesIO() as buffer:
                market_df.to_parquet(buffer, index=False, engine='pyarrow')
                buffer.seek(0)
                client.write(hdfs_path, buffer.read(), overwrite=True)

        logger.info("Pipeline Complete. Data distributed across HDFS partitions.")

    except Exception as e:
        logger.error(f"Pipeline failed: {e}")

if __name__ == "__main__":
    run_hdfs_pipeline()
