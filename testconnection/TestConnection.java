import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TestConnection {
	public static void main(String[] args) {

		final String URL = "jdbc:oracle:thin:@localhost:1521:XE";
		final String USER = "system";
		final String PASS = "password";
		final String SQL = "select * from test_table where 1=?";

		try (Connection conn = DriverManager.getConnection(URL,USER,PASS);
			PreparedStatement ps = conn.prepareStatement(SQL)){

			ps.setInt(1, 1);
			//ps.setString(2, "tanaka");

            try(ResultSet rs = ps.executeQuery()){
                while (rs.next()) {
                    System.out.println(
                    	rs.getInt("id") + " " +
                    	rs.getString("first_name") + " " +
                        rs.getString("last_name"));
                }           
            }
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			System.out.println("処理が完了しました");
		}
	}
}