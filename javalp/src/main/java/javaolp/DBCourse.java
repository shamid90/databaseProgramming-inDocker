package javaolp;

import java.sql.*;
import java.util.*;

public class DBCourse {

	@Override
	public String toString() {
		return "DBCourse [course_id=" + course_id + ", title=" + title  + ", main_category=" + main_category
							+ ", sub_category=" + sub_category + ", course_rate=" + course_rate
							+ ", price=" + price + ", instructor_id=" + instructor_id 
							+ ", is_persisted=" + is_persisted + "]";
	}
	final Optional<Integer> course_id;
	final String title;
	final String main_category;
	final String sub_category;
	final Optional<Double> course_rate;
	final Optional<Integer> price;
	final Integer instructor_id;
	final boolean is_persisted;
	//constructor 1 (course_id, course_rate, price: empty)
	DBCourse (String title, String main_category, String sub_category, Integer instructor_id) {
		this.course_id = Optional.empty();
		this.title = title;
		this.main_category = main_category;
		this.sub_category = sub_category;
		this.course_rate = Optional.empty();
		this.price = Optional.empty();
		this.instructor_id = instructor_id;
		this.is_persisted = false;
	}
	//constructor 2
	private DBCourse (Integer course_id, String title, String main_category, String sub_category, Double course_rate, Integer price, Integer instructor_id, boolean is_persisted) {
		this.course_id = Optional.of(course_id);
		this.title = title;
		this.main_category = main_category;
		this.sub_category = sub_category;
		this.course_rate = Optional.of(course_rate);
		this.price = Optional.of(price);
		this.instructor_id = instructor_id;
		this.is_persisted = is_persisted;
	}

	static List<DBCourse> all(Connection c, String sch) throws SQLException {
		// returns All Courses
		List<DBCourse> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".course;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBCourse(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getDouble(5),rs.getInt(6), rs.getInt(7),true));
			}
		} catch(SQLException e){
			System.out.println(e.getMessage());
		} finally {
			try {
				if(rs != null)
					rs.close();
			}catch(SQLException e) {
				System.out.println(e.getMessage());
			}
		}
		return li;
	}

}
