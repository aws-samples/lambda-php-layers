<?php declare(strict_types=1);

/**
 * @param string $message
 * @return void
 */
function success(string $message)
{
	echo prefix() . " ✓ $message" . PHP_EOL;
}

/**
 * @param string $message
 * @return void
 */
function error(string $message)
{
	echo prefix() . " ⨯ $message" . PHP_EOL;
//	$extensions = get_loaded_extensions();
//	sort($extensions);
//	print_r(implode(", ", $extensions));
	exit(1);
}

function prefix(): string
{
	return $_SERVER['argv'][1];
}
