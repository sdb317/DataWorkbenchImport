# How to import a curated Rodent sheet

The workflow takes a Google Sheet from **Phase 7** of [Tier 1 Curation Rodents](https://trello.com/b/cAi9cKeW/tier-1-curation-rodents) and applies a number of **ETL** (Extract, Transform & Load) operations to post to the the **DataWorkbench**.

From there, the **KnowledgeGraph** extracts it and, based on the state, adds it to either the **curated** or **public** views.

Note: This only works on Microsoft Windows

## Setup

Initially a **parent folder** needs to be created and all the supporting software needs to be installed from [GitHub](https://github.com/sdb317/DataWorkbenchImport).

Then, for each import session, the following steps need to be performed in order:

## ![http://www.animatedimages.org/data/media/43/animated-letter-image-0187.gif](http://www.animatedimages.org/data/media/43/animated-letter-image-0187.gif) xtract

The aim is to reliably extract the data from the spreadsheet into a format that is easily manipulated i.e. XML.

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

Save this sheet as the same name but with type ```.xlsm``` i.e. macro-enabled.

Close Excel

### - Insert the DataWorkbench tab

Open the new macro-enabled Excel workbook. Also open DataWorkbench.xlsm and DataWorkbench.xlam from the parent folder.
The xlsx file can be deleted at this point.

Type ```<Alt><F11>``` to open the Visual Basic editor.

In the VBA Project Explorer, right-click on the new workbook and select ```Import File...```

Import ```DataWorkbench.bas``` from the parent folder.

Go back to Excel and type ```<Alt><F8>```. Then select ```InsertDataWorkbenchSheet``` and click on ```Run```.

### - Check the formulae

A ```DataWorkbench``` tab should have been added to the workbook. You can (and should) now close DataWorkbench.xlsm to avoid confusion.

You should enter the expected item counts in the 'count' cells in the second column i.e. If you have 3 subjects in the ```MINDS``` tab, enter 3 in the subject count.

Also check the formulae look good and that there are no ```#VALUE``` errors!

### - Export the XML

Name/value ranges are automatically created and exported to individual files in the data folder.

Run this export by selecting the ```DataWorkbench``` tab, typing ```<Alt><F8>``` and selecting ```Extract```.

Then check the XML files have been created.


## ![](http://www.animatedimages.org/data/media/43/animated-letter-image-0201.gif)ransform

The XML data now needs to be tranformed into a format that can be understood by the DataWorkbench REST api.

### - Generate the JSON

This step converts the XML files to JSON, by means of an XSLT transform. In addition, indiidual samples are added to their corresponding subject, and indiidual subjects are added to their corresponding specimen.

Using the **Import Rodent** UI, click on ```Transform```.

Check the JSON files have been created.


## ![http://www.animatedimages.org/data/media/43/animated-letter-image-0204.gif](http://www.animatedimages.org/data/media/43/animated-letter-image-0204.gif) oad

Finally the JSON data needs to be sent to the DataWorkbench REST api in order to be viewable in the UI.

### - Upload to the DataWorkbench

Using the **Import Rodent** UI, click on ```Load```.

Refresh the DataWorkbench 'Navigator' and check that all the data items are correct.


