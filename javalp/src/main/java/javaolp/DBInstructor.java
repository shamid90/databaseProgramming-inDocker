package javaolp;

import java.sql.*;
import java.util.*;

public class DBInstructor {

	@Override
	public String toString() {
		return "DBInstructor [instructor_id=" + instructor_id + ", first_name=" + first_name  + ", last_name=" + last_name
							+ ", email=" + email + ", instructor_rate=" + instructor_rate
							+ ", description=" + description + ", is_persisted=" + is_persisted + "]";
	}
	final Optional<Integer> instructor_id;
	final String first_name;
	final String last_name;
	final String email;
	final Optional<Integer> instructor_rate;
	final Optional<String> description;
	final boolean is_persisted;
	//constructor 1 (instructor_id, instructor_rate, description: empty)
	DBInstructor (String first_name, String last_name, String email) {
		this.instructor_id = Optional.empty();
		this.first_name = first_name;
		this.last_name = last_name;
		this.email = email;
		this.instructor_rate = Optional.empty();
		this.description = Optional.empty();
		this.is_persisted = false;
	}
	//constructor 2
	private DBInstructor (Integer instructor_id, String first_name, String last_name, String email, Integer instructor_rate, String description, boolean is_persisted) {
		this.instructor_id = Optional.of(instructor_id);
		this.first_name = first_name;
		this.last_name = last_name;
		this.email = email;
		this.instructor_rate = Optional.of(instructor_rate);
		this.description = Optional.ofNullable(description); // for string we must use Optional.OfNullable, otherwise possibility of NullPointerException
		this.is_persisted = is_persisted;
	}

	static List<DBInstructor> all(Connection c, String sch) throws SQLException {
		// returns All Instructors
		List<DBInstructor> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".instructor;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBInstructor(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getInt(5),rs.getString(6),true));
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
