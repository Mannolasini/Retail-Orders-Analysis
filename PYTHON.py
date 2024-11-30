import pandas
from pandas import to_datetime as datetime


# pyodbc when using docker to connec to sql

# sal to connect to server
data = pandas.read_csv("orders.csv", na_values=['Not Available', 'unknown'])
print(type(data))
data.columns = data.columns.str.lower()
data.columns = data.columns.str.replace(" ","_")
data["discount"]=data["list_price"]*data["discount_percent"]*0.01
data["sale_price"] = data["list_price"]-data["discount"]
data["profit"] = data["sale_price"]-data["cost_price"]
data["order_date"] = datetime(data["order_date"], format="%Y-%m-%d")

data.drop(columns=["list_price","cost_price","discount_percent"],inplace=True)
print(data)
#now load the data into sql server


from sqlalchemy import create_engine
import urllib

# Replace with your own database connection details
server = 'localhost'  # SQL Server instance
port = '1433'         # Default SQL Server port
database = 'master'
username = 'YOUR-USERNAME'
password = 'YOUR-PASSWORD'

# Create the connection string for SQLAlchemy
conn_str = (
    f"mssql+pyodbc://{username}:{urllib.parse.quote(password)}@{server}:{port}/{database}"
    "?driver=ODBC+Driver+17+for+SQL+Server"
)

# Create an SQLAlchemy engine
engine = create_engine(conn_str)

# Example: Writing a DataFrame to SQL Server
data.to_sql('data_orders', con=engine, index=False, if_exists='append')






