package javaolp;

import java.sql.*;
import java.util.*;

public class DBRegistration {

	@Override
	public String toString() {
		return "DBRegistration [student_id=" + student_id + ", course_id=" + course_id + ", registration_date=" + registration_date
				+ ", is_persisted=" + is_persisted + "]";
	}
	final Integer student_id;
	final Integer course_id;
	final Optional<Timestamp> registration_date;
	final boolean is_persisted;
	//constructor 1 (registration_date: empty)
	DBRegistration (Integer student_id, Integer course_id) {
		this.student_id = student_id;
		this.course_id = course_id;
		this.registration_date = Optional.empty();
		this.is_persisted = false;
	}
	//constructor 2
	private DBRegistration (Integer student_id, Integer course_id, Timestamp registration_date, boolean is_persisted) {
		this.student_id = student_id;
		this.course_id = course_id;
		this.registration_date = Optional.of(registration_date);
		this.is_persisted = is_persisted;
	}

	static List<DBRegistration> all(Connection c, String sch) throws SQLException {
		// returns All Registrations
		List<DBRegistration> li = new ArrayList<>();
		String query = "SELECT * FROM " + sch + ".registration;";
		Statement stm = null;
		ResultSet rs = null;
		try {
			stm = c.createStatement();
			rs = stm.executeQuery(query);
			while (rs.next()) {
				li.add(new DBRegistration(rs.getInt(1),rs.getInt(2),rs.getTimestamp(3),true));
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
	
	
	//INSERT new row
	DBRegistration persist(Connection c, String sch) throws SQLException {
		String query = "INSERT INTO " + sch + ".registration (sid, cid) VALUES (?,?);";
		try (PreparedStatement stm = c.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)){
			stm.setInt(1, this.student_id);
			stm.setInt(2, this.course_id);
			stm.execute();
			ResultSet res = stm.getGeneratedKeys();

			if(res != null && res.next()){
				return new DBRegistration(this.student_id, this.course_id, res.getTimestamp(3), true);
     		}
			else {
				return new DBRegistration(this.student_id, this.course_id);
			}
		}
		//persisted registration
	}
	
	//Delete on row
	static void delete(Connection c, String sch, int std_id, int crs_id) {
		String query = "DELETE FROM " + sch + ".registration WHERE sid = "+ std_id + "AND cid = " + crs_id + ";";
		Statement stm = null;
		try{
			stm = c.createStatement();
			stm.execute(query);
		} catch(SQLException e){
			System.out.println(e.getMessage());
		}
		
		//delete registration
	}

}