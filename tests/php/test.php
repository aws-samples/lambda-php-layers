<?php declare(strict_types=1);

require_once __DIR__ . '/utils.php';

[$file, $image, $tag, $arch] = $_SERVER['argv'];

$is_layer = strpos($tag, 'devel') === false;

success("The image is: " . $image);
success("The tag is: " . $tag);
success("The arch is: " . $arch);

$coreExtensions = [
	'date'       => class_exists(\DateTime::class),
	'filter'     => filter_var('elonniu@amazon.com', FILTER_VALIDATE_EMAIL),
	'hash'       => hash('md5', 'aws') === 'ac68bbf921d953d1cfab916cb6120864',
	'libxml'     => class_exists(\LibXMLError::class),
	'openssl'    => strlen(openssl_random_pseudo_bytes(1)) === 1,
	'pcntl'      => function_exists('pcntl_fork'),
	'pcre'       => function_exists('preg_match') && preg_match('/abc/', 'abcde', $matches) && $matches[0] === 'abc',
	'readline'   => READLINE_LIB,
	'reflection' => class_exists(\ReflectionClass::class),
	'session'    => session_status() === PHP_SESSION_NONE,
	'zip'        => class_exists(\ZipArchive::class),
	'zlib'       => md5(gzcompress('abcde')) === 'db245560922b42f1935e73e20b30980e',
];
foreach ($coreExtensions as $extension => $test) {
	if (!$test) {
		error($extension . ' core extension was not loaded');
	}
	success("[Core extension] $extension => $test");
}

$extensions = [
	'awscrt'     => extension_loaded('awscrt'),
	'igbinary'   => extension_loaded('igbinary'),
	'imagick'    => extension_loaded('imagick'),
	'mysqlnd'    => extension_loaded('mysqlnd'),
	'mysqli'     => function_exists('mysqli_connect'),
	'cURL'       => function_exists('curl_init'),
	'json'       => function_exists('json_encode'),
	'bcmath'     => function_exists('bcadd'),
	'ctype'      => function_exists('ctype_digit'),
	'dom'        => class_exists(\DOMDocument::class),
	'exif'       => function_exists('exif_imagetype'),
	'fileinfo'   => function_exists('finfo_file'),
	'ftp'        => function_exists('ftp_connect'),
	'redis'      => class_exists(\Redis::class),
	'random'     => function_exists('random_int'),
	'gd'         => function_exists('gd_info'),
	'gettext'    => function_exists('gettext'),
	'iconv'      => function_exists('iconv_strlen'),
	'mbstring'   => function_exists('mb_strlen'),
	'opcache'    => extension_loaded('Zend OPcache') && ini_get('opcache.enable') == 1 && ini_get('opcache.enable_cli') == 1,
	'pdo'        => class_exists(\PDO::class),
	'pdo_mysql'  => extension_loaded('pdo_mysql'),
	'pdo_sqlite' => extension_loaded('pdo_sqlite'),
	'phar'       => extension_loaded('phar'),
	'posix'      => function_exists('posix_getpgid'),
	'simplexml'  => class_exists(\SimpleXMLElement::class),
	'sodium'     => SODIUM_LIBRARY_VERSION,
	'soap'       => class_exists(\SoapClient::class),
	'sockets'    => function_exists('socket_connect'),
	'SPL'        => class_exists(\SplQueue::class),
	'sqlite3'    => class_exists(\SQLite3::class),
	'tokenizer'  => function_exists('token_get_all'),
	'xml'        => function_exists('xml_parse'),
	'xmlreader'  => class_exists(\XMLReader::class),
	'xmlwriter'  => class_exists(\XMLWriter::class),
	'xsl'        => class_exists(\XSLTProcessor::class),
];
foreach ($extensions as $extension => $test) {
	if (!$test) {
		error($extension . ' extension was not loaded');
	}
	success("[Extension] $extension => $test");
}


if ($is_layer) {
	$extensionsDisabledByDefault = [
		'intl'      => class_exists(\Collator::class),
		'apcu'      => function_exists('apcu_add'),
		'pdo_pgsql' => extension_loaded('pdo_pgsql'),
	];
	foreach ($extensionsDisabledByDefault as $extension => $test) {
		
		if ($test) {
			error($extension . ' extension was not supposed to be loaded');
		}
		
		success("[Extension] $extension (disabled)");
	}
}


