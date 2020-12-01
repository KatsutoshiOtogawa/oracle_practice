package main

import (
	"database/sql"
	fmt "fmt"
	"os"
	"strconv"

	_ "github.com/mattn/go-oci8"
) // 入出力フォーマットを実装したパッケージ

func main() {
	// password = "xkhxnv08WOuhbgtdwpq"
	// 以下のように接続して
	connectStr := "system/" + os.Getenv("ORACLE_PASSWORD") + "@localhost/XEPDB1"
	db, err := sql.Open("oci8", connectStr)
	if err != nil {
		fmt.Printf("DbOpen Error: %s", err)
		return
	}
	defer db.Close()

	// 以下のようにクエリ投げる
	// rows, err := db.Query("SELECT * FROM test_table")
	rows, err := db.Query("SELECT * FROM HR.Countries")
	if err != nil {
		fmt.Printf("Query Error: %s", err)
		//return err
	}
	defer rows.Close()

	// // 以下のようにデータを取得する
	for rows.Next() {
		var CountryID string
		var CountryName string
		var ResionID int

		rows.Scan(&CountryID, &CountryName, &ResionID)

		fmt.Println(CountryID + " " + CountryName + " " + strconv.Itoa(ResionID))
	}
}
