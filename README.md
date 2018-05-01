# How to import a Rodent sheet

The workflow takes a Google Sheet from **Phase 6B** of **Tier 1 Curation Rodents** and applies a number of **ETL** (Extract, Transform & Load) operations to post to the the **DataWorkbench**.

From there the **KnowledgeGraph** extracts it and, based on the state, adds it to either the _curated_ or _public_ views.

Note: This only works on Microsoft Windows

## Process

Initially a **parent folder** needs to be created and all the supporting software needs to be installed from GitHub.

Then, for each import session, the following steps need to be performed in order:

### - Create a specific sub-folder for this import session

Create a sub-folder (aka session folder) , preferably using some form of naming convention, and in that sub-folder create a further sub-folder (aka data folder) named 'DataWorkbench' so that the structure is as follows:

\ParentFolder
\ParentFolder\MyImportSession
\ParentFolder\MyImportSession\DataWorkbench

### - Convert the Google Sheet to a local, macro-enabled Excel workbook

The Google Sheet is saved locally in the session folder, using ```File > Download as > Microsoft Excel (*.xlsx)```.
Be aware that the names used for the Google Sheet are very long and cause Excel problems, therefore use something shorter, even the Google unique id e.g. '10H8hb3hJSJ3Vx_N8LeuuJjSjhO8pMoGa6NehAh6HEms'.

Then open the sheet in Excel. Invariably, errors will be reported here. These can be ignored.
Select all cells in all sheets by right-clicking on the first tab and choosing ```Select All Sheets``` and then clicking top-left to select all cells.
Right-click on a column heading and set all column widths to 20. Right-click on a row heading and set all heights to 15.

Save this sheet as the same name but type ```.xlsm``` i.e. macro-enabled.

Close Excel

### - Insert the DataWorkbench tab

Open the new 
