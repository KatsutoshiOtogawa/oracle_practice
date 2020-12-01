package com.sample;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.util.Properties;
import java.util.Objects;
import oracle.jdbc.pool.OracleDataSource;
import oracle.jdbc.OracleConnection;
import java.sql.DatabaseMetaData;

/**
 * Hello world!
 *
 */
public class App {
    public static void main(String[] args) {
        Properties info = new Properties();     
		final String DB_URL = "jdbc:oracle:thin:@localhost:1521/XEPDB1";
		final String DB_USER = "system";
		// final String SQL = "select * from test_table where 1=? and first_name=?";

		final String SQL = "SELECT * FROM HR.Countries";

		info.put(OracleConnection.CONNECTION_PROPERTY_USER_NAME, DB_USER);
		info.put(OracleConnection.CONNECTION_PROPERTY_PASSWORD, System.getenv("ORACLE_PASSWORD"));          
		info.put(OracleConnection.CONNECTION_PROPERTY_DEFAULT_ROW_PREFETCH, "20"); 
		OracleDataSource ods = null;
		try{
			ods = new OracleDataSource();
			ods.setURL(DB_URL);    
			ods.setConnectionProperties(info);
		} catch (SQLException e) {
			e.printStackTrace();
			System.exit(1);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}finally{
			if(Objects.isNull(ods)){
				System.out.println("OracleDataSourceの初期化に失敗しました。");
				System.exit(1);
			}
		}
		
		try {
			OracleConnection connection = (OracleConnection) ods.getConnection();

			PreparedStatement ps = connection.prepareStatement(SQL);
			
			ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                System.out.println(
                    rs.getString("country_id") + " " +
                    rs.getString("country_name") + " " +
                    rs.getInt("region_id")
                );
			}           
			
            // ps.setInt(1, 1);
            // ps.setString(2, "Tony");
    
            // ResultSet rs = ps.executeQuery();
            // while (rs.next()) {
            //     System.out.println(
            //         rs.getInt("id") + " " +
            //         rs.getString("first_name") + " " +
            //         rs.getString("second_name")
            //     );
            // }           
             
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			System.out.println("処理が完了しました");
		}
    }
}
