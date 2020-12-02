// Learn more about F# at http://docs.microsoft.com/dotnet/fsharp

open System

open Oracle.ManagedDataAccess.Client
// Define a function to construct a message to print


[<EntryPoint>]
let main argv =
    let orclCon:OracleConnection = new OracleConnection(String.Format(
                    "user id=system; password={0}; data source=XEPDB1"
                    ,Environment.GetEnvironmentVariable "ORACLE_PASSWORD"
                    )
                )
                // パイプで書き直す。
    0 // return an integer exit code

    // OracleConnection orclCon = null;

    //         try
    //         {
    //             // Open a connection
    //             orclCon = new OracleConnection(String.Format(
    //                 "user id=system; password={0}; data source=XEPDB1"
    //                 ,Environment.GetEnvironmentVariable("ORACLE_PASSWORD")
    //                 )
    //             );

    //             orclCon.Open();

    //             // Execute simple select statement that returns first 10 names from EMPLOYEES table
    //             OracleCommand orclCmd = orclCon.CreateCommand();
    //             orclCmd.CommandText = @"
    //             SELECT * 
    //             FROM HR.Countries
    //             ";
    //             OracleDataReader rdr = orclCmd.ExecuteReader();

    //             while (rdr.Read()){
    //                 Console.WriteLine(rdr.GetString(0) + " " + rdr.GetString(1) + " " + rdr.GetString(2));
    //             }
    //             Console.ReadLine();

    //             rdr.Dispose();
    //             orclCmd.Dispose();
    //         }
    //         finally
    //         {
    //             // Close the connection
    //             if (null != orclCon)
    //                 orclCon.Close();
    //         }
