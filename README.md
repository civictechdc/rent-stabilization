DC rent stabalization policy change impact project
==================================================

The Rent Stabilization Program in the District of Columbia ([DC Code § 42–3502.05](http://dccode.org/simple/sections/42-3502.05.html)) covers all rental units _except_ those for which the building permit was issued after December 31, 1975 or the owner owns four or fewer rental units within the District, not necessarily in the same building (more or less).

The purpose of this project is to evaluate how a change in rent stabilization policy would affect rental properties in the District.

To do this, we are using two datasets from the District's open data catalog:

The Computer Assisted Mass Appraisal (CAMA) database.

This database comes in three files:

* [residential properties](http://opendata.dc.gov/datasets/c5fb3fbe4c694a59a6eef7bf5f8bc49a_25), which seems to mean house-like structures, but may or may not be rental
* [condominum properties](http://opendata.dc.gov/datasets/d6c70978daa8461992658b69dccb3dbf_24), which maybe means condominums where occupants are owners --- and so rent stabilization does not apply --- but I am not sure if that's really what the file contains
* [commercial properties](http://opendata.dc.gov/datasets/e53572ef8f124631b965709da8200167_23), which _includes_ large rental apartment complexes

This database has these key fields:

* `usecode`: A [real property use code](http://opendata.dc.gov/datasets/9d8e09cb7403445ca8b4354cac6ae776_54) ([PDF](http://otr.cfo.dc.gov/sites/default/files/dc/sites/otr/publication/attachments/Use%20codes.pdf)). This code says what type of property it is. For the residential properties, this code can _possibly_ distinguish non-rental residential properties (or for multi-unit rental properties, a guess at how many units are owned by the renter, which might not be covered by rent stabilization?). For commercial properties, this code distinguishes large rental properties from other sorts of non-residential commercial properties.

* `ayb`: "The earliest time the main portion of the building was built," which is the closest data point we have for when its building permit was issued.

* `num_units`: The number of residential units in the property, which is the closest data point we have for how many units an owner owns in the District (ignoring that an owner might own units in multiple buildings).

* `ownername`: The name of the owner. To the extent names are consistent throughout the dataset and uniquely identify a person (both of which are probably false), this might help establish if an owner owns more than four rental units across multiple properties.

* `ssl` (square suffix and lot), which identifies properties (by location), which we can use to connect this data to other property databases.

(Download and save the dataset files as `Residential_CAMA.csv`, `Condominium_CAMA.csv`, and `Commercial_CAMA.csv`.)

The CAMS data appears in the [DCRA Property Information Verification System](http://pivs.dcra.dc.gov/PIVS/Results.asp), except use codes. Use codes appear in the [DC OTR Real Property Assessment Database](https://www.taxpayerservicecenter.com/RP_Search.jsp?search_type=Assessment).

The [Master Address Record Address Points](http://opendata.dc.gov/datasets/aa514416aaf74fdc94748f1e56e7cc8a_0) dataset provides address and geographic information for properties, based on the same SSL identifiers:

* Full street addresses (i.e. the textual address) of each property.

* Ward, ANC (Advisory Neighborhood Commission) number, SMD (Single Member District) number, and Census block.

* This dataset also has a residential unit count which might be the same as the CAMA data.

* Both this and the CAMA datasets have geospatial (latitude/longitude) coordinates of properties.

(Download it as `Address_Points.csv`.)

