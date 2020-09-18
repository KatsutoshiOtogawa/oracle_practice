import cx_Oracle

try:
    connection = cx_Oracle.connect("system", "password", "localhost")

    cursor = connection.cursor()

    cursor.execute("""
            SELECT * FROM test_table where 1=:one """,
            one = 1
            )
    for id,fname, lname in cursor:
        print("{} {} {}".format(id,fname,lname))
except cx_Oracle._Error as e:
    print(e.message)
finally:
    cursor.close()

