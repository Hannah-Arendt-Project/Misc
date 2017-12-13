# ocrTGImportprepare
This Bash script prepares the scanned images (literature) and OCR data for the import into [TextGridLab](https://textgrid.de/). What it does:

* Creates a copy of the input directory
* Runs the [OCR2TEI](https://github.com/Hannah-Arendt-Project/OCR2TEI) converter on the copy
* Converts the TIF files to JPEG
* Creates a Fakesimilies and TEI_OCR directory, creates subdirectory for each volume
* the Fakesimilies and TEI_OCR directories are meant for importing into TextGrid Lab

## Installation
Needs *nix with bash. Make sure that you have 

* bash available
* Java runtime 1.8 or better installed
* ImageMagick convert installed
* sed installed
* Download the latest release of [ocr2tei.jar](https://github.com/Hannah-Arendt-Project/OCR2TEI/releases) and copy it into the same directory as this script.

Download the latest release of this script, make it executable:
`chmod +x ocrTGImportprepare.sh`

## Usage

Create a new project in TextGrid Lab. Create the Aggregation "Schema". Import the latest version of the RelaxNG schema "transcriptionsSchema.rng" into the schema folder. Right click on the imported transcriptionsSchema file and click "copy URI". This copies the internal TextGrid ID into the clipboard. We use this to link the XML schema with the TEI XML documents.

### Synchronize the owncloud with the scans & ocr files
The first step is that you setup the [OwnCloud Desktop Client](https://owncloud.org/install/) and synchronize the Hannah Arendt folder.

### Run this script
Create the output directory where you want to store the output. Take note of the path. Then simply cd into the directory where you have copied ocrTGImportprepare.sh. (`cd /path/to/ocrTGImportprepare`). Then run
`./ocrTGImportprepare.sh /path/to/Owncloud/Volume /path/to/output/directory schemaURI`
Where

* /path/to/Owncloud/Volume is the path to the owncloud and the desired volume (e.g. /Users/Johannes/ownCloud/Hannah-Arendt/Scans/Band-III
* /path/to/output/ is the path to the desired output directory (e.g. /Users/Johannes/Documents/Arendt/TextGridOCRImport)
* schemaURI is the TextGridURI for the XML schema (you have copied this URI into the clipboard as the first step (see usage paragraph), e.g. textgrid:3cscb.0

### Import into TextGrid Lab
Simply open TextGrid Lab with the project you want to import the files. Then drag and drop the folder "Faksimilies" and "TEI_OCR" from the `/path/to/output/directory` into TextGrid Lab and click import. 