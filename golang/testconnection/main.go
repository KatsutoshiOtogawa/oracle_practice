package main

import (
	"database/sql"
	fmt "fmt"
	"strconv"

	_ "github.com/mattn/go-oci8"
) // 入出力フォーマットを実装したパッケージ

func main() {
	password = "xkhxnv08WOuhbgtdwpq"
	// 以下のように接続して
	connectStr := "system/" + password + "@localhost/XE"
	db, err := sql.Open("oci8", connectStr)
	if err != nil {
		fmt.Printf("DbOpen Error: %s", err)
		return
	}
	defer db.Close()

	// 以下のようにクエリ投げる
	rows, err := db.Query("SELECT * FROM test_table")
	if err != nil {
		fmt.Printf("Query Error: %s", err)
		//return err
	}
	defer rows.Close()

	// // 以下のようにデータを取得する
	for rows.Next() {
		var id int
		var firstName string
		var secondName string

		rows.Scan(&id, &firstName, &secondName)

		fmt.Println(strconv.Itoa(id) + " " + firstName + " " + secondName)
	}
}
