springfield = School.find_or_create_by!(name: "Springfield Academy", code: "SPA-01") do |school|
  school.address = "742 Evergreen Terrace"
end

shelbyville = School.find_or_create_by!(name: "Shelbyville Prep", code: "SVP-01") do |school|
  school.address = "12 Industrial Blvd"
end

bart = Student.find_or_create_by!(email: "bart@springfield.edu") do |student|
  student.school = springfield
  student.first_name = "Bart"
  student.last_name = "Simpson"
  student.enrollment_number = "SPA-101"
end

lisa = Student.find_or_create_by!(email: "lisa@springfield.edu") do |student|
  student.school = springfield
  student.first_name = "Lisa"
  student.last_name = "Simpson"
  student.enrollment_number = "SPA-102"
end

milhouse = Student.find_or_create_by!(email: "milhouse@springfield.edu") do |student|
  student.school = springfield
  student.first_name = "Milhouse"
  student.last_name = "Van Houten"
  student.enrollment_number = "SPA-103"
end

martin = Student.find_or_create_by!(email: "martin@shelbyville.edu") do |student|
  student.school = shelbyville
  student.first_name = "Martin"
  student.last_name = "Prince"
  student.enrollment_number = "SVP-201"
end

algebra_hw = Homework.find_or_create_by!(title: "Quadratic Equations Lab", school: springfield) do |hw|
  hw.subject = "Mathematics"
  hw.description = "Complete practice questions 1 through 15 from textbook section 4.2."
  hw.max_score = 100
  hw.due_date = Date.current + 5.days
end

literature_hw = Homework.find_or_create_by!(title: "To Kill A Mockingbird Analysis", school: springfield) do |hw|
  hw.subject = "Literature"
  hw.description = "Write a 500-word critical essay focusing on Atticus Finch moral stance."
  hw.max_score = 50
  hw.due_date = Date.current + 3.days
end

science_hw = Homework.find_or_create_by!(title: "Solar System Exploration", school: shelbyville) do |hw|
  hw.subject = "Astronomy"
  hw.description = "Chart planetary orbits and submit scale diagrams."
  hw.max_score = 100
  hw.due_date = Date.current + 7.days
end

Marking.find_or_create_by!(homework: algebra_hw, student: lisa) do |marking|
  marking.score = 99.0
  marking.status = "marked"
  marking.feedback = "Flawless mathematical rigor and clear step-by-step proofs."
  marking.marked_at = Time.current
end

Marking.find_or_create_by!(homework: algebra_hw, student: bart) do |marking|
  marking.score = 55.0
  marking.status = "marked"
  marking.feedback = "Formulas are applied incorrectly in section 2. Please consult teacher."
  marking.marked_at = Time.current
end

Marking.find_or_create_by!(homework: algebra_hw, student: milhouse) do |marking|
  marking.status = "pending"
end

Marking.find_or_create_by!(homework: literature_hw, student: lisa) do |marking|
  marking.score = 48.0
  marking.status = "marked"
  marking.feedback = "Superb literary analysis and vocabulary."
  marking.marked_at = Time.current
end

Marking.find_or_create_by!(homework: literature_hw, student: bart) do |marking|
  marking.status = "resubmission_required"
  marking.feedback = "Essay did not meet the 500-word minimum length requirement."
end

Marking.find_or_create_by!(homework: science_hw, student: martin) do |marking|
  marking.score = 96.0
  marking.status = "marked"
  marking.feedback = "Exemplary celestial model."
  marking.marked_at = Time.current
end
