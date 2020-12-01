<?php
require 'vendor/autoload.php';

// Using Medoo namespace
use Medoo\Medoo;

// Initialize
$database = new Medoo([
    'database_type' => 'oracle',
    'database_name' => 'PDBXE1',
    'server' => 'localhost',
    'username' => 'system',
    'password' => getenv("ORACLE_PASSWORD")
]);


$data = $database->select('HR.COUNTRIES', [
    'COUNTRY_NAME',
    'COUNTRY_ID'
], [
    'REGION_ID' => 2
]);

echo json_encode($data);

// HR.COUNTRIES

    // error_reporting(E_ALL);
    // ini_set('display_errors', '1');
    // $conn = oci_connect('system', 'password', 'localhost:1521/afaaaa8597f12df7e055000000000001/XE');
    // $stid = oci_parse($conn, 'SELECT * FROM test_table');
    // oci_execute($stid);
    // echo "\n";
    // while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
    //   foreach ($row as $item) {
    //     echo $item ."\n";
    //    }
    // }
    // echo "aaa";
?>