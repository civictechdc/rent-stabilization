# Download the datasets used for our analysis:

# Create "data" subdirectory.
if (!file.exists("data")) dir.create("data")

# Computer Assisted Mass Appraisal (CAMA) datasets

# Residential (CAMA) - 106875 x 47
# UNIT: Building
download.file("http://opendata.dc.gov/datasets/c5fb3fbe4c694a59a6eef7bf5f8bc49a_25.csv",
              "data/cama_residential.csv")

# Conduminium (CAMA) - 48650 x 24
# UNIT: Unit
download.file("http://opendata.dc.gov/datasets/d6c70978daa8461992658b69dccb3dbf_24.csv",
              "data/cama_condominium.csv")

# Commercial (CAMA) - 19827 x 18
# UNIT: Building
download.file("http://opendata.dc.gov/datasets/e53572ef8f124631b965709da8200167_23.csv",
              "data/cama_commercial.csv")

# Geospatial datasets

# DC's Wards
download.file("http://opendata.dc.gov/datasets/0ef47379cbae44e88267c01eaec2ff6e_31.zip",
              "data/ward.zip")
system("cd data && unzip -u ward.zip")

# DC's Single Member Districts, which also gives the Advisory Neighborhood Commision number
# (This can't be used to determine wards because there is an ANC that crosses a ward boundary.)
download.file("http://opendata.dc.gov/datasets/890415458c4c40c3ada2a3c48e3d9e59_21.zip",
	          "data/smd.zip")
system("cd data && unzip -u smd.zip")
