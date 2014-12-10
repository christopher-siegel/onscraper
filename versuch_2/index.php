<?php $url = "http://onlinewerk.info";

//
//
// ACHTUNG: LIMITIERTE ANZAHL AN TOKENS! Insgesamt nur 30 Stück, wodurch diese Variante nutzlos ist.
//
//

 // INCLUDE THE phpToPDF.php FILE
require("phpToPDF/phpToPDF.php"); 

// SET YOUR PDF OPTIONS
// FOR ALL AVAILABLE OPTIONS, VISIT HERE:  http://phptopdf.com/documentation/
$pdf_options = array(
  "source_type" => 'url',
  "source" => $url,
  "action" => 'save',
  "save_directory" => '',
  "file_name" => 'test.pdf');

// CALL THE phptopdf FUNCTION WITH THE OPTIONS SET ABOVE
phptopdf($pdf_options);

// OPTIONAL - PUT A LINK TO DOWNLOAD THE PDF YOU JUST CREATED
echo ("<a href='test.pdf'>See Your PDF</a>");
?>