using System;

using Oracle.ManagedDataAccess.Client;
namespace App
{
    class Program
    {
        static void Main(string[] args)
        {

            OracleConnection orclCon = null;

            try
            {
                // Open a connection
                orclCon = new OracleConnection(String.Format(
                    "user id=system; password={0}; data source=XEPDB1"
                    ,Environment.GetEnvironmentVariable("ORACLE_PASSWORD")
                    )
                );

                
                orclCon.Open();

                // Execute simple select statement that returns first 10 names from EMPLOYEES table
                OracleCommand orclCmd = orclCon.CreateCommand();
                orclCmd.CommandText = @"
                SELECT * 
                FROM HR.Countries
                ";
                OracleDataReader rdr = orclCmd.ExecuteReader();

                while (rdr.Read()){
                    Console.WriteLine(rdr.GetString(0) + " " + rdr.GetString(1) + " " + rdr.GetString(2));
                }
                Console.ReadLine();

                rdr.Dispose();
                orclCmd.Dispose();
            }
            finally
            {
                // Close the connection
                if (null != orclCon)
                    orclCon.Close();
            }
        }
    }
}
