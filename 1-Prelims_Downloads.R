# Prelims: Downloads
# Author: Nate 
# Purpose: Download Computer Assisted Mass Appraisal (CAMA) datasets.


# Residential (CAMA) - 106875 x 47
# UNIT: Building = Unit
download.file("http://opendata.dc.gov/datasets/c5fb3fbe4c694a59a6eef7bf5f8bc49a_25.csv",
              "Residential.csv")
# Conduminium (CAMA) - 48650 x 24
# UNIT: Unit
download.file("http://opendata.dc.gov/datasets/d6c70978daa8461992658b69dccb3dbf_24.csv",
              "Condominium.csv")
# Commercial (CAMA) - 19827 x 18
# UNIT: Building
download.file("http://opendata.dc.gov/datasets/e53572ef8f124631b965709da8200167_23.csv",
              "Commercial.csv")