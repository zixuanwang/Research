<?php
require_once ("phpFlickr.php");
function downloadPhoto($f, $photo, $outputDir) {
	// image is renamed by its md5.
	$url = $f->buildPhotoURL ( $photo );
	$photoId = $photo ['id'];
	$info = $f->photos_getInfo ( $photoId );
	$photoPath = $outputDir . '/' . $photoId . '.jpg';
	file_put_contents ( $photoPath, file_get_contents ( $url ) );
	// save image info to json
	$fp = fopen ( $outputDir . '/' . $photoId . '.json', 'w' );
	fwrite ( $fp, json_encode ( $info ) );
	fclose ( $fp );
}
function downloadByName($f, $name, $outputDir) {
	// create the directory for the people
	$nameDir = $outputDir . '/' . $name;
	if (! is_dir ( $nameDir )) {
		mkdir ( $nameDir );
	}
	$page = 1;
	$perPage = 500;
	while ( true ) {
		$photos = $f->photos_search ( array (
				"tags" => $name,
				"tag_mode" => "all",
				"has_geo" => 1,
				"per_page" => $perPage,
				"page" => $page 
		) );
		if (count ( $photos ['photo'] ) == 0) {
			break;
		}
		foreach ( $photos ['photo'] as $photo ) {
			downloadPhoto ( $f, $photo, $nameDir );
		}
		++ $page;
	}
}

$f = new phpFlickr ( "d018cabac0391dcf99aedf4f5ac47768" );

// read pubfig file line by line
$nameArray = array ();
$handle = @fopen ( "pubfig_140.txt", "r" );
if ($handle) {
	while ( ($buffer = fgets ( $handle, 4096 )) !== false ) {
		$nameArray [] = trim ( $buffer );
	}
	if (! feof ( $handle )) {
		echo "Error: unexpected fgets() fail\n";
	}
	fclose ( $handle );
}

foreach ( $nameArray as $name ) {
	downloadByName ( $f, $name, '/export/data/phpflickr/data' );
	echo 'downloading ' . $name . '...';
	flush();
}

?>