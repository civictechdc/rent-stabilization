DC rent stabalization policy change impact project
==================================================

The Project
-----------

The Rent Stabilization Program in the District of Columbia ([DC Code § 42–3502.05](http://dccode.org/simple/sections/42-3502.05.html)) covers all rental units _except_ those for which the building permit was issued after December 31, 1975 or the owner owns four or fewer rental units within the District, not necessarily in the same building (more or less).

The purpose of this project is to evaluate how a change in rent stabilization policy would affect rental properties in the District.

We are working with the [Coalition for Nonprofit Housing & Economic Development](https://www.cnhed.org/). Our team members are [Marie Whittaker](https://github.com/mseew), [Nate Banion](https://github.com/nbanion), Harlan Harris, [Svyat Nakonechny](https://github.com/snakonechny), [Nicole Kelly](https://github.com/nikelly1326), Chris Given, Ariana Carella, Heidi Thompson, [Ursula Kaczmarek](https://github.com/ursulakaczmarek), [Brigid McDermott](https://github.com/br-mcdermott), and [Josh Tauberer](https://github.com/joshdata). The project began at Code for DC's National Data of Civic Hacking event on June 4, 2016.

Background Links
----------------

* [District Measured Report (2016)](https://districtmeasured.com/2016/03/23/how-can-the-rent-be-so-high-in-dc-when-almost-two-thirds-of-all-rental-units-in-the-district-are-subject-torent-control-a-small-number-of-spoiler-units-with-high-turnover-may-be-the-reason/)

* [Urban Institute Report (2011)](http://www.urban.org/research/publication/rent-control-report-district-columbia/view/full_report) ([pdf](http://www.urban.org/sites/default/files/alfresco/publication-pdfs/412347-A-Rent-Control-Report-for-the-District-of-Columbia.PDF)) (a project in collaboration with [Neighborhood Info DC](http://www.neighborhoodinfodc.org/index.html))

* [Urban Institute - Affordable Housing Needs Assessment for the District of Columbia Phase II (2015)](http://www.urban.org/sites/default/files/alfresco/publication-pdfs/2000214-Affordable-Housing-Needs-Assessment-for-the-District-of-Columbia.pdf)

* [RAD Rent Control Exemption form](http://dhcd.dc.gov/sites/default/files/dc/sites/dhcd/publication/attachments/Form%201%20-%20RAD%20Registration%20Claim%20of%20Exemption%20Form%202--RY%20Final_0.pdf)

* [DC Preservation Catalog](http://www.neighborhoodinfodc.org/dcpreservationcatalog/)

* [Example of building age map (NYC)](http://io.morphocode.com/urban-layers/)

* [GGW: How old are DC's buildings? This map will tell you (2014)](http://greatergreaterwashington.org/post/23143/how-old-are-dcs-buildings-this-map-will-tell-you/)

* [How do SSLs work?](http://dcaddresscoordinates.blogspot.com/2009/08/square-suffix-lot-ssl.html)

What we know about the DC rent control law
------------------------------------------

1. Every housing accommodation or rental unit in the District must be registered with the Rental Accommodations Division (RAD)

  a. once registered, every unit is either given registration number if it IS subject to rental control; or an exemption number if it is not

  b. Changes in ownership or management of a building are required to be reported to the RAD 

2. A rental unit is considered subject to rent control UNLESS it meets one of the following [exceptions](http://dccode.org/simple/sections/42-3502.05.html) AND the owner has requested and received an exemption number:

  a. The housing accommodation is owned by the the District or federal government.

  b. The mortgage or rent is of the housing accommodation is subsidized by the District or federal government.

  c. The housing accommodation's building permit (for construction of a new building) was issued after 12/31/1975.

  d. The building permit for a newly created unit added onto an existing building was issued after 1/1/1980.

  e. The rental unit is one of four or fewer aggregate rental units (whether in the same building or not) owned by the same "natural" person (or up to four people, but not a company).

  f. The rental unit is in a building that has been vacant and has not been rented since 1/1/1985.

  g. The rental unit is in a building that was previously exempt under § 206(a)(4) of the Rental Housing Act of 1980.

  h. The rental unit is owned by a cooperative association with no more than four members and no more than four rental units.

  i. The rental unit is in a building under a Building Improvement Plan or other DCHD multi-family assistance program.

3. Rent Increases:

  a. [If vacant](http://dccode.org/simple/sections/42-3502.13.html), the rent may be a) increased by 10% or b) changed to the rent of a comparable unit in same structure (but not more than a 30% increase).

  b. If occupied, the previous rent increase must be at least 12 months ago. For current tenants, it may be increased by the [CPI-W](http://www.bls.gov/regions/mid-atlantic/news-release/consumerpriceindex_washingtondc.htm) + 2% but not more than 10%. For elderly tenants, the maximum increase is 5%.

Reference Data
--------------

Three previous reports, [District Measured's 2016 analysis of DC OTR data](https://districtmeasured.com/2016/03/23/how-can-the-rent-be-so-high-in-dc-when-almost-two-thirds-of-all-rental-units-in-the-district-are-subject-torent-control-a-small-number-of-spoiler-units-with-high-turnover-may-be-the-reason/), [Urban Institute's 2011 report](http://www.urban.org/research/publication/rent-control-report-district-columbia/view/full_report), and [Urban Institute's 2015 affordable housing report](http://www.urban.org/sites/default/files/alfresco/publication-pdfs/2000214-Affordable-Housing-Needs-Assessment-for-the-District-of-Columbia.pdf), provide baseline data to compare our analysis with. Their findings are saved in [reference-data.csv](reference-data.csv) for convenience.

Data Sources
------------

Our primary data source is the Computer Assisted Mass Appraisal (CAMA) database ([residential properties](http://opendata.dc.gov/datasets/c5fb3fbe4c694a59a6eef7bf5f8bc49a_25), meaning house structures; [condominum properties](http://opendata.dc.gov/datasets/d6c70978daa8461992658b69dccb3dbf_24), which may still be rented out; [commercial properties](http://opendata.dc.gov/datasets/e53572ef8f124631b965709da8200167_23), which includes large rental apartment buildings).

This database has these key fields:

* `usecode`: A [real property use code](http://opendata.dc.gov/datasets/9d8e09cb7403445ca8b4354cac6ae776_54) ([PDF](http://otr.cfo.dc.gov/sites/default/files/dc/sites/otr/publication/attachments/Use%20codes.pdf)). This code says what type of property it is. This code distinguishes large rental properties from other sorts of non-residential commercial properties. It also can provide a guess for how many residential units are in a structure. [use-codes.csv](use-codes.csv) contains our determination for which use codes indicate a residential space (i.e. plausibly rental) and guesses for the number of units within such residential structures.

* `ayb`: "The earliest time the main portion of the building was built," which is the closest data point we have for when its building permit was issued.

* `num_units`: The number of residential units in the property, which we are using to estimate the number of rental units owned by the same owner. This field is only present in the commercial file, unfortunately, and for the other files we're guessing the number of units in the strucuture based on the use code.

* `ownername`: The name of the owner. To the extent names are consistent throughout the dataset and uniquely identify a person (both of which are probably false), this might help establish if an owner owns more than four rental units across multiple properties.

* `ssl` (square suffix and lot), which identifies properties (by location), which we can use to connect this data to other property databases. Unfortunately condos are assigned individual SSLs which do not easily line up with the SSL of the building in other datasets, but the [ITSPE dataset](http://opendata.dc.gov/datasets/014f4b4f94ea461498bfeba877d92319_56?uiTab=table) may be able to do that.

For checking data points by hand, the CAMA data appears in the [DCRA Property Information Verification System](http://pivs.dcra.dc.gov/PIVS/Search.aspx), except for use codes. Use codes appear in the [DC OTR Real Property Assessment Database](https://www.taxpayerservicecenter.com/RP_Search.jsp?search_type=Assessment).

Other datasets we may use are [CPI-W](http://download.bls.gov/pub/time.series/cw/), [building footprints shapefile](http://opendata.dc.gov/datasets/a657b34942564aa8b06f293cb0934cbd_1), [DCRA/ Certificate of Occupancy data](https://www.dropbox.com/sh/qic9irkt8eyxbv8/AACQIK6RLlfYPhCySUqNwJRMa?dl=0), [HUD Data (info on federal public housing and section 8 units, since those are not rent controlled)](http://data.hud.gov/data_sets.html) in particular [Public Housing Agency (PHA) Inventory](http://www.hud.gov/offices/pih/programs/hcv/ogddata/lowrent-s8-units.zip), and the [Master Address Record Address Points](http://opendata.dc.gov/datasets/aa514416aaf74fdc94748f1e56e7cc8a_0) which has ward/ANC/SMD information for each SSL.

Reproducing Our Analysis
------------------------

Our analysis is performed in R with the following scripts run in this order:

* `download-datasets.R` fetches the datasets and saves them into the `data` directory.
* `residential-units.R` creates a single table that lists every known residential unit in the district, by including the units from the CAMA datasets and expanding the buildings listed in the CAMA dataset into their units. Where the number of units in a structure is not given in the CAMA file, we use the use code to guess (see above). This step is unfortunately very slow.

Analysis
--------

We are in the process of analyzing the data.

See [Harlan's visualization demo](https://harlanh.shinyapps.io/rent-stabilization-policy-viz/) (it's a work in process using simulated data).

1. How many buildings in DC have 4 or fewer units?  
  Answer 1: We used ACS (2010-2014) data to cross-tab housing units by the unit count of their building. *48% of housing units* in DC are in buildings with 4 or fewer units. We do not have exact information from ACS on the number of buildings, but the number of buildings is within the range of ~199,000-221,000 buildings.

Blog posts
----------

* [Why We Hack, by Joshua Tauberer 6/4/2016](https://medium.com/@joshuatauberer/why-we-hack-db430cb1aee0)
* [Simulating Rent Stabilization Policy at the National Day of Civic Hacking, by Harlan Harris 6/5/2016](https://medium.com/@HarlanH/simulating-rent-stabilization-policy-at-the-national-day-of-civic-hacking-4f44b808387c#.sin5uywyb)
