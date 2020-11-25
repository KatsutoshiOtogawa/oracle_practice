<?php
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
    $conn = oci_connect('system', 'password', 'localhost:1521/afaaaa8597f12df7e055000000000001/XE');
    $stid = oci_parse($conn, 'SELECT * FROM test_table');
    oci_execute($stid);
    echo "\n";
    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
      foreach ($row as $item) {
        echo $item ."\n";
       }
    }
    echo "aaa";
?>