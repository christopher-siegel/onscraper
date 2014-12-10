<?php $url = "http://kevinw.de";

/**
 * Not recommended because we cannot set a timeout parameter
 * and it's not allowed by many hosts (http://davidwalsh.name/curl-download).
 */
// $html = file_get_contents($url);


/**
 * Use curl to get HTML content
 */
function getHTML($url,$timeout)
{
       $ch = curl_init($url); // initialize curl with given url
       curl_setopt($ch, CURLOPT_USERAGENT, $_SERVER["HTTP_USER_AGENT"]); // set  useragent
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // write the response to a variable
       curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true); // follow redirects if any
       curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout); // max. seconds to execute
       curl_setopt($ch, CURLOPT_FAILONERROR, 1); // stop when it encounters an error
       return @curl_exec($ch);
}

$html = getHTML( $url, 10 );



// Möglichkeit 1 (funktioniert)
$content = "
<page>
    <h1>Exemple d'utilisation</h1>
    <br>
    Ceci est un <b>exemple d'utilisation</b>
    de <a href='http://html2pdf.fr/'>HTML2PDF</a>.<br>
</page>";

// Möglichkeit 2: Die Inhalte sind unformatiert
$dom = new domDocument;
/*** load the html into the object ***/
$dom->loadHTML($html);
/*** the table by its tag name ***/
$content = "<page>" . $dom->getElementsByTagName('body')->item(0)->nodeValue . "</page>";



/**
 * http://html2pdf.fr/en/default
 */
require_once(dirname(__FILE__).'/html2pdf/html2pdf.class.php');
    $html2pdf = new HTML2PDF('P','A4','de');
    $html2pdf->WriteHTML($content);
    
    // PDF anzeigen
    // $html2pdf->Output('test.pdf');

    // PDF herunterladen
    // $html2pdf->Output('test.pdf', 'D');  

    // PDF speichern
    $html2pdf->Output('output/test.pdf', 'F');	// http://wiki.spipu.net/doku.php?id=html2pdf%3aen%3av4%3aoutput
    echo "Datei gespeichert im Ordner 'Output'!";
