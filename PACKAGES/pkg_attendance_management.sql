-- PACKAGE FOR ATTENDANCES MANAGEMENT OPERATIONS
CREATE OR REPLACE PACKAGE pkg_attendance_management
IS
  PROCEDURE insert_attendance(
    v_student_id    attendances.student_id%TYPE,
    v_schedule_id   attendances.schedule_id%TYPE,
    v_status        attendances.status%TYPE
  );
    PROCEDURE update_attendance(
    v_student_id    attendances.student_id%TYPE,
    v_schedule_id   attendances.schedule_id%TYPE,
    v_status        attendances.status%TYPE
  );
  PROCEDURE generate_attendance_report(
      v_schedule_id attendances.schedule_id%TYPE,
      v_group_id    groups.group_id%TYPE
    );
  FUNCTION check_student_leaves(v_student_id attendances.student_id%TYPE) RETURN NUMBER;
END pkg_attendance_management;
/

CREATE OR REPLACE PACKAGE BODY pkg_attendance_management
IS
  -- PROCEDURE TO ADD A NEW ATTENDANCE RECORD
  PROCEDURE insert_attendance(
    v_student_id    attendances.student_id%TYPE,
    v_schedule_id   attendances.schedule_id%TYPE,
    v_status        attendances.status%TYPE
  )
  IS
  BEGIN
    INSERT INTO attendances(student_id, schedule_id, status)
    VALUES (v_student_id, v_schedule_id, v_status);

    DBMS_OUTPUT.PUT_LINE('Attendance added successfully.');
    
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      DBMS_OUTPUT.PUT_LINE('Error: A record with this combination already exists.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred. SQLCODE: ' || SQLCODE || ', SQLERRM: ' || SQLERRM);
  END insert_attendance;



  -- PROCEDURE TO UPDATE ATTENDANCE RECORD
  PROCEDURE update_attendance(
    v_student_id    attendances.student_id%TYPE,
    v_schedule_id   attendances.schedule_id%TYPE,
    v_status        attendances.status%TYPE
  )
  IS
  BEGIN
    UPDATE attendances
    SET status = v_status
    WHERE student_id = v_student_id
      AND schedule_id = v_schedule_id;

    IF SQL%ROWCOUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('No matching record found for the provided student and schedule IDs.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Attendance status updated successfully.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred. SQLCODE: ' || SQLCODE || ', SQLERRM: ' || SQLERRM);
  END update_attendance;



  -- PROCEDURE TO GENERATE REPORT ABOUT ATTENDANCES IN GROUP
  PROCEDURE generate_attendance_report(
      v_schedule_id attendances.schedule_id%TYPE,
      v_group_id    groups.group_id%TYPE
    )
    IS
        CURSOR attendance_cursor IS
            SELECT s.student_id, s.first_name, s.last_name, a.status
            FROM students s
            LEFT JOIN attendances a ON s.student_id = a.student_id
            WHERE a.schedule_id = v_schedule_id;

        v_report_line VARCHAR2(500);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Attendance Report for Schedule ID: ' || v_schedule_id);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Student ID | First Name | Last Name | Status');
        
        FOR attendance_record IN attendance_cursor LOOP
            v_report_line := attendance_record.student_id || ' | ' ||
                            attendance_record.first_name || ' | ' ||
                            attendance_record.last_name || ' | ' ||
                            NVL(attendance_record.status, 'Not Recorded');
            DBMS_OUTPUT.PUT_LINE(v_report_line);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Report Generation Completed.');

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred. SQLCODE: ' || SQLCODE || ', SQLERRM: ' || SQLERRM);
    END generate_attendance_report;
  

  
  -- FUNCTION TO CHECK HOW MANY LEAVES STUDENT HAVE
  FUNCTION check_student_leaves(v_student_id attendances.student_id%TYPE)
  RETURN NUMBER
  IS
      v_leaves NUMBER := 0;
  BEGIN
      SELECT COUNT(*)
      INTO v_leaves
      FROM attendances
      WHERE student_id = v_student_id
        AND status = 0;

      RETURN v_leaves;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('No records found for the provided student ID.');
          RETURN 0;
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error occurred. SQLCODE: ' || SQLCODE || ', SQLERRM: ' || SQLERRM);
          RETURN -1;
  END check_student_leaves;
END pkg_attendance_management;