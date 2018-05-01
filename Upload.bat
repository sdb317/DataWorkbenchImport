rem msxsl "%~1.xml" Import.xslt Type=%2 SubType=%3 >"%~1.unformatted.json"
rem python -m json.tool "%~1.unformatted.json" >"%~1.json"
rem del "%~1.unformatted.json"
cscript //nologo Import.wsf //job:Upload "%~1.json" %4 >"%~1.log"
