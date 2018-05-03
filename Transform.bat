msxsl "%~1.xml" Import.xslt Type=%2 SubType=%3 >"%~1.unformatted.json"
python -m json.tool "%~1.unformatted.json" >"%~1.json"
del "%~1.unformatted.json"
