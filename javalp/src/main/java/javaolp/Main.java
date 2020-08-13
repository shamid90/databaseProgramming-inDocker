package javaolp;

import java.sql.*;
import java.util.*;


public class Main {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
//		Scanner sc = new Scanner(System.in);
//		System.out.println("please enter the DB user:");
//		String user = sc.next();
//		System.out.println("please enter the DB user password:");
//		String password = sc.next();
//		System.out.println("please enter the DB schema:");
//		String sch = sc.next();
//		
//		
//		try(Connection c = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", user, password)){
//			System.out.println("Connected to Database");
//			
//			String schema = sch;
			
			
		try(Connection c = DriverManager.getConnection("jdbc:postgresql://localhost:5435/lmsceo", "lmsceo", "4b570")){
			System.out.println("Connected to Database");
			
			c.setAutoCommit(false);
			
			String schema = "lms_sch1";
									
			all_student(c, schema);
			
			//Create a new student (C)
			final DBStudent newStudent = (new DBStudent("attui", "att_ui@mlu.de", "uzm14nsm")).persist(c, schema);
			
			//Update the password of the student (U)
			newStudent.changeEmail("att_ui@gmail.com").persist(c, schema);
			
			c.commit();
			
			//Read the table student to see the changes (R)
			all_student(c, schema);
			
			//The student Read the available courses
			all_course(c, schema);
			
			//The student will register in one course
			final DBRegistration stdCourse1_reg = (new DBRegistration(11, 3)).persist(c, schema);
			final DBRegistration stdCourse2_reg = (new DBRegistration(11, 7)).persist(c, schema);
			
			all_registration(c, schema);
			
			c.commit();
			
			//The student cancel one of his/her courses (D)
			DBRegistration.delete(c, schema, 11, 7);
			
			c.commit();
			
			all_registration(c, schema);
			
//			all_instructor(c, schema);
			
//			all_course_content(c, schema);
			
//			all_feedback(c, schema);
			
//			all_progress(c, schema);
			
			
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		

	}
	
	private static void all_student(Connection c, String schema) throws SQLException {
		//print the whole table: student
		System.out.println("Table student:");
		List<DBStudent> all_student = DBStudent.all(c, schema);
		for(int i=0; i<all_student.size();i++) {
			System.out.println(all_student.get(i));
		}
		
	}
	
	
	private static void all_course(Connection c, String schema) throws SQLException {
		//print the whole table: course
		System.out.println("Table course:");
		List<DBCourse> all_course = DBCourse.all(c, schema);
		for(int i=0; i<all_course.size();i++) {
			System.out.println(all_course.get(i));
		}
		
	}

	private static void all_registration(Connection c, String schema) throws SQLException {
		//print the whole table: registration

		System.out.println("Table registration:");
		List<DBRegistration> all_registration = DBRegistration.all(c, schema);
		for(int i=0; i<all_registration.size();i++) {
			System.out.println(all_registration.get(i));
		}
		
	}
	
	private static void all_instructor(Connection c, String schema) throws SQLException {
		//print the whole table: instructor
		System.out.println("Table instructor:");
		List<DBInstructor> all_instructor = DBInstructor.all(c, schema);
		for(int i=0; i<all_instructor.size();i++) {
			System.out.println(all_instructor.get(i));
		}
		
	}
	
	private static void all_course_content(Connection c, String schema) throws SQLException {
		//print the whole table: course_content
		System.out.println("Table course_content:");
		List<DBCourseContent> all_course_content = DBCourseContent.all(c, schema);
		for(int i=0; i<all_course_content.size();i++) {
			System.out.println(all_course_content.get(i));
		}
		
	}
	
	
	private static void all_feedback(Connection c, String schema) throws SQLException {
		//print the whole table: course_content
		System.out.println("Table feedback:");
		List<DBFeedback> all_DBfeedback = DBFeedback.all(c, schema);
		for(int i=0; i<all_DBfeedback.size();i++) {
			System.out.println(all_DBfeedback.get(i));
		}
		
	}
	
	private static void all_progress(Connection c, String schema) throws SQLException {
		//print the whole table: course_content
		System.out.println("Table progress:");
		List<DBProgress> all_progress = DBProgress.all(c, schema);
		for(int i=0; i<all_progress.size();i++) {
			System.out.println(all_progress.get(i));
		}
		
	}
	

}
